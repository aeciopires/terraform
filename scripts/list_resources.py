"""List the resources this learning path creates, on the emulators or on the real clouds.

Every resource name starts with "<prefix>-<environment>" (e.g. "lt-dev"), so the
script asks each service for its resources and keeps those whose name starts
with the given prefix. It only reads: it never creates, changes or deletes.

AWS uses boto3, which honours AWS_ENDPOINT_URL: with the floci variables from
.env loaded it talks to floci, without them to AWS (your usual credentials).

GCP uses the services' REST APIs. With --gcp-endpoint (or FLOCI_GCP_ENDPOINT)
it talks to floci-gcp; otherwise to Google, with the token from
GOOGLE_OAUTH_ACCESS_TOKEN or `gcloud auth print-access-token`.

Examples:
    uv run python scripts/list_resources.py aws --prefix lt-dev --region us-east-1
    uv run python scripts/list_resources.py gcp --prefix lt-dev --project floci-local
    uv run python scripts/list_resources.py all --prefix lt- --json

References:
    https://docs.aws.amazon.com/sdkref/latest/guide/feature-ss-endpoints.html
    https://cloud.google.com/storage/docs/json_api/v1/buckets/list
    https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.topics/list
    https://cloud.google.com/run/docs/reference/rest/v2/projects.locations.services/list
    https://cloud.google.com/sql/docs/postgres/admin-api/rest/v1beta4/instances/list
    https://cloud.google.com/compute/docs/reference/rest/v1/networks/list
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import urllib.error
import urllib.request
from collections.abc import Callable, Iterable
from dataclasses import asdict, dataclass
from typing import Any

JsonGetter = Callable[[str, str], dict[str, Any]]


@dataclass(frozen=True)
class Resource:
    """One resource found in a cloud."""

    cloud: str
    kind: str
    name: str
    detail: str = ""


def starts_with(name: str, prefix: str) -> bool:
    """True when the resource name belongs to this learning path."""
    return name.startswith(prefix)


def last_segment(value: str, separator: str) -> str:
    """Last part of an ARN, URL or GCP resource path (the short name)."""
    return value.rstrip(separator).rsplit(separator, 1)[-1]


# --- AWS --------------------------------------------------------------------


def list_aws(prefix: str, region: str, session: Any | None = None) -> list[Resource]:
    """List the AWS resources whose name starts with prefix, service by service."""
    if session is None:
        import boto3

        session = boto3.session.Session(region_name=region)

    found: list[Resource] = []

    def add(kind: str, name: str, detail: str = "") -> None:
        if starts_with(name, prefix):
            found.append(Resource("aws", kind, name, detail))

    s3 = session.client("s3")
    for bucket in s3.list_buckets().get("Buckets", []):
        add("s3-bucket", bucket["Name"])

    sqs = session.client("sqs")
    for url in sqs.list_queues(QueueNamePrefix=prefix).get("QueueUrls", []):
        add("sqs-queue", last_segment(url, "/"), url)

    sns = session.client("sns")
    for page in sns.get_paginator("list_topics").paginate():
        for topic in page.get("Topics", []):
            add("sns-topic", last_segment(topic["TopicArn"], ":"), topic["TopicArn"])

    ec2 = session.client("ec2")
    vpcs = ec2.describe_vpcs(Filters=[{"Name": "tag:Name", "Values": [f"{prefix}*"]}])
    for vpc in vpcs.get("Vpcs", []):
        name = next((t["Value"] for t in vpc.get("Tags", []) if t["Key"] == "Name"), "")
        add("vpc", name, f"{vpc['VpcId']} {vpc.get('CidrBlock', '')}".strip())

    elbv2 = session.client("elbv2")
    for lb in elbv2.describe_load_balancers().get("LoadBalancers", []):
        add("load-balancer", lb["LoadBalancerName"], lb.get("DNSName", ""))

    ecs = session.client("ecs")
    for arn in ecs.list_clusters().get("clusterArns", []):
        add("ecs-cluster", last_segment(arn, "/"), arn)

    rds = session.client("rds")
    for db in rds.describe_db_instances().get("DBInstances", []):
        endpoint = db.get("Endpoint") or {}
        address = f"{endpoint.get('Address', '')}:{endpoint.get('Port', '')}"
        add("rds-instance", db["DBInstanceIdentifier"], address)

    return found


# --- GCP --------------------------------------------------------------------

GCP_REAL_ENDPOINTS = {
    "storage": "https://storage.googleapis.com",
    "pubsub": "https://pubsub.googleapis.com",
    "run": "https://run.googleapis.com",
    "sql": "https://sqladmin.googleapis.com",
    "compute": "https://compute.googleapis.com",
}


@dataclass(frozen=True)
class GcpListing:
    """How to list one kind of GCP resource with its REST API."""

    kind: str
    service: str
    path: str  # may use {project} and {region}
    items_key: str
    detail_key: str = ""


GCP_LISTINGS = (
    GcpListing("gcs-bucket", "storage", "/storage/v1/b?project={project}", "items", "location"),
    GcpListing("pubsub-topic", "pubsub", "/v1/projects/{project}/topics", "topics"),
    GcpListing(
        "pubsub-subscription", "pubsub", "/v1/projects/{project}/subscriptions", "subscriptions"
    ),
    GcpListing(
        "cloud-run-service",
        "run",
        "/v2/projects/{project}/locations/{region}/services",
        "services",
        "uri",
    ),
    GcpListing(
        "cloud-sql-instance",
        "sql",
        "/sql/v1beta4/projects/{project}/instances",
        "items",
        "databaseVersion",
    ),
    GcpListing("vpc-network", "compute", "/compute/v1/projects/{project}/global/networks", "items"),
)


def gcp_url(listing: GcpListing, endpoint: str, project: str, region: str) -> str:
    """Full URL of a listing: the emulator's endpoint, or the service's real one."""
    base = endpoint.rstrip("/") if endpoint else GCP_REAL_ENDPOINTS[listing.service]
    return base + listing.path.format(project=project, region=region)


def http_get_json(url: str, token: str) -> dict[str, Any]:
    """GET a Google REST API and decode its JSON body."""
    request = urllib.request.Request(url, headers={"Authorization": f"Bearer {token}"})
    with urllib.request.urlopen(request, timeout=30) as response:  # noqa: S310 - fixed hosts
        body: dict[str, Any] = json.loads(response.read() or b"{}")
        return body


def gcp_token(endpoint: str) -> str:
    """The OAuth token to send: any value for floci-gcp, a real one for Google."""
    token = os.environ.get("GOOGLE_OAUTH_ACCESS_TOKEN", "")
    if token or endpoint:
        return token or "floci-fake-token"
    result = subprocess.run(
        ["gcloud", "auth", "print-access-token"], capture_output=True, text=True, check=True
    )
    return result.stdout.strip()


def list_gcp(
    prefix: str,
    project: str,
    region: str,
    endpoint: str,
    get_json: JsonGetter = http_get_json,
    token: str | None = None,
) -> tuple[list[Resource], list[str]]:
    """List the GCP resources whose name starts with prefix.

    Returns the resources and one warning per listing that failed (for
    example an API floci-gcp does not emulate), so one failure does not hide
    the other results.
    """
    token = gcp_token(endpoint) if token is None else token
    found: list[Resource] = []
    warnings: list[str] = []
    for listing in GCP_LISTINGS:
        url = gcp_url(listing, endpoint, project, region)
        try:
            body = get_json(url, token)
        except (urllib.error.URLError, OSError, ValueError) as error:
            warnings.append(f"{listing.kind}: could not list ({error})")
            continue
        for item in body.get(listing.items_key, []):
            name = last_segment(str(item.get("name", "")), "/")
            if starts_with(name, prefix):
                detail = str(item.get(listing.detail_key, "")) if listing.detail_key else ""
                found.append(Resource("gcp", listing.kind, name, detail))
    return found, warnings


# --- output -----------------------------------------------------------------


def format_table(resources: Iterable[Resource]) -> str:
    """Resources as an aligned text table, sorted by cloud, kind and name."""
    rows = sorted(resources, key=lambda r: (r.cloud, r.kind, r.name))
    if not rows:
        return "No resources found."
    header = ("CLOUD", "KIND", "NAME", "DETAIL")
    table = [header] + [(r.cloud, r.kind, r.name, r.detail) for r in rows]
    widths = [max(len(row[i]) for row in table) for i in range(3)]
    lines = [
        f"{row[0]:<{widths[0]}}  {row[1]:<{widths[1]}}  {row[2]:<{widths[2]}}  {row[3]}".rstrip()
        for row in table
    ]
    return "\n".join(lines)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n", 1)[0])
    parser.add_argument("cloud", choices=["aws", "gcp", "all"], help="which cloud to list")
    parser.add_argument("--prefix", default="lt-", help="name prefix to keep (default: lt-)")
    parser.add_argument(
        "--region",
        default=os.environ.get("AWS_DEFAULT_REGION", "us-east-1"),
        help="AWS region (default: $AWS_DEFAULT_REGION or us-east-1)",
    )
    parser.add_argument(
        "--project",
        default=os.environ.get("GOOGLE_CLOUD_PROJECT", "floci-local"),
        help="GCP project ID (default: $GOOGLE_CLOUD_PROJECT or floci-local)",
    )
    parser.add_argument(
        "--gcp-region",
        default="us-central1",
        help="GCP region for Cloud Run (default: us-central1)",
    )
    parser.add_argument(
        "--gcp-endpoint",
        default=os.environ.get("FLOCI_GCP_ENDPOINT", ""),
        help="floci-gcp URL (default: $FLOCI_GCP_ENDPOINT; empty = real Google APIs)",
    )
    parser.add_argument("--json", action="store_true", help="print JSON instead of a table")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    resources: list[Resource] = []
    warnings: list[str] = []
    if args.cloud in ("aws", "all"):
        resources += list_aws(args.prefix, args.region)
    if args.cloud in ("gcp", "all"):
        gcp_resources, warnings = list_gcp(
            args.prefix, args.project, args.gcp_region, args.gcp_endpoint
        )
        resources += gcp_resources
    for warning in warnings:
        print(f"warning: {warning}", file=sys.stderr)
    if args.json:
        print(json.dumps([asdict(r) for r in resources], indent=2))
    else:
        print(format_table(resources))
    return 0


if __name__ == "__main__":
    sys.exit(main())
