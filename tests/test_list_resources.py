"""Unit tests of scripts/list_resources.py - no cloud, no emulator.

AWS calls go to a fake boto3 session and GCP calls to a fake JSON getter,
so the tests check the script's logic (filtering, naming, URLs, output).
"""

from __future__ import annotations

import json
import urllib.error
from typing import Any

import list_resources as lr
import pytest


class FakePaginator:
    def __init__(self, pages: list[dict[str, Any]]) -> None:
        self.pages = pages

    def paginate(self) -> list[dict[str, Any]]:
        return self.pages


class FakeClient:
    """Answers the few boto3 calls the script makes with canned data."""

    def __init__(self, service: str) -> None:
        self.service = service
        self.calls: list[tuple[str, dict[str, Any]]] = []

    def list_buckets(self) -> dict[str, Any]:
        return {"Buckets": [{"Name": "lt-dev-000000000000-us-east-1-assets"}, {"Name": "other"}]}

    def list_queues(self, **kwargs: Any) -> dict[str, Any]:
        self.calls.append(("list_queues", kwargs))
        return {"QueueUrls": ["http://floci:4566/000000000000/lt-dev-orders-billing"]}

    def get_paginator(self, name: str) -> FakePaginator:
        assert name == "list_topics"
        return FakePaginator(
            [
                {"Topics": [{"TopicArn": "arn:aws:sns:us-east-1:000000000000:lt-dev-orders"}]},
                {"Topics": [{"TopicArn": "arn:aws:sns:us-east-1:000000000000:someone-else"}]},
            ]
        )

    def describe_vpcs(self, **kwargs: Any) -> dict[str, Any]:
        self.calls.append(("describe_vpcs", kwargs))
        return {
            "Vpcs": [
                {
                    "VpcId": "vpc-1",
                    "CidrBlock": "10.10.0.0/16",
                    "Tags": [{"Key": "Name", "Value": "lt-dev-vpc"}],
                }
            ]
        }

    def describe_load_balancers(self) -> dict[str, Any]:
        return {"LoadBalancers": [{"LoadBalancerName": "lt-dev-alb", "DNSName": "alb.elb.floci"}]}

    def list_clusters(self) -> dict[str, Any]:
        return {"clusterArns": ["arn:aws:ecs:us-east-1:000000000000:cluster/lt-dev-ecs"]}

    def describe_db_instances(self) -> dict[str, Any]:
        return {
            "DBInstances": [
                {
                    "DBInstanceIdentifier": "lt-dev-postgres",
                    "Endpoint": {"Address": "172.27.0.2", "Port": 7001},
                }
            ]
        }


class FakeSession:
    def __init__(self) -> None:
        self.clients: dict[str, FakeClient] = {}

    def client(self, service: str) -> FakeClient:
        return self.clients.setdefault(service, FakeClient(service))


def test_list_aws_keeps_only_the_prefix_and_extracts_short_names() -> None:
    session = FakeSession()
    found = lr.list_aws("lt-dev", "us-east-1", session=session)
    by_kind = {r.kind: r for r in found}

    assert set(by_kind) == {
        "s3-bucket",
        "sqs-queue",
        "sns-topic",
        "vpc",
        "load-balancer",
        "ecs-cluster",
        "rds-instance",
    }
    assert by_kind["sqs-queue"].name == "lt-dev-orders-billing"
    assert by_kind["sns-topic"].name == "lt-dev-orders"
    assert by_kind["ecs-cluster"].name == "lt-dev-ecs"
    assert by_kind["rds-instance"].detail == "172.27.0.2:7001"
    assert by_kind["vpc"].detail == "vpc-1 10.10.0.0/16"
    assert all(r.cloud == "aws" for r in found)


def test_list_aws_filters_on_the_server_where_the_api_allows_it() -> None:
    session = FakeSession()
    lr.list_aws("lt-dev", "us-east-1", session=session)

    assert ("list_queues", {"QueueNamePrefix": "lt-dev"}) in session.clients["sqs"].calls
    vpc_filter = session.clients["ec2"].calls[0][1]["Filters"][0]
    assert vpc_filter == {"Name": "tag:Name", "Values": ["lt-dev*"]}


@pytest.mark.parametrize(
    ("value", "separator", "expected"),
    [
        ("arn:aws:sns:us-east-1:000000000000:topic", ":", "topic"),
        ("http://floci:4566/000000000000/queue", "/", "queue"),
        ("projects/p/topics/lt-dev-orders", "/", "lt-dev-orders"),
        ("trailing/slash/", "/", "slash"),
    ],
)
def test_last_segment(value: str, separator: str, expected: str) -> None:
    assert lr.last_segment(value, separator) == expected


def test_gcp_url_uses_the_emulator_or_the_real_api() -> None:
    run = next(x for x in lr.GCP_LISTINGS if x.kind == "cloud-run-service")

    assert lr.gcp_url(run, "http://localhost:4588/", "p", "us-central1") == (
        "http://localhost:4588/v2/projects/p/locations/us-central1/services"
    )
    assert lr.gcp_url(run, "", "p", "us-central1") == (
        "https://run.googleapis.com/v2/projects/p/locations/us-central1/services"
    )


def test_list_gcp_filters_and_reports_failed_apis_as_warnings() -> None:
    answers = {
        "/storage/v1/b": {
            "items": [
                {"name": "lt-dev-floci-local-assets", "location": "US"},
                {"name": "unrelated"},
            ]
        },
        "/topics": {"topics": [{"name": "projects/floci-local/topics/lt-dev-orders"}]},
        "/subscriptions": {"subscriptions": [{"name": "projects/floci-local/subscriptions/x"}]},
        "/services": {
            "services": [
                {"name": "projects/p/locations/r/services/lt-dev-web", "uri": "http://lt-dev-web"}
            ]
        },
        "/instances": {},
    }

    def fake_get(url: str, token: str) -> dict[str, Any]:
        assert token == "t"
        if "/compute/" in url:
            raise urllib.error.HTTPError(url, 405, "Method Not Allowed", {}, None)  # type: ignore[arg-type]
        return next(v for k, v in answers.items() if k in url)

    found, warnings = lr.list_gcp(
        "lt-dev",
        "floci-local",
        "us-central1",
        "http://localhost:4588",
        get_json=fake_get,
        token="t",
    )

    assert [(r.kind, r.name, r.detail) for r in found] == [
        ("gcs-bucket", "lt-dev-floci-local-assets", "US"),
        ("pubsub-topic", "lt-dev-orders", ""),
        ("cloud-run-service", "lt-dev-web", "http://lt-dev-web"),
    ]
    assert len(warnings) == 1 and warnings[0].startswith("vpc-network")


def test_gcp_token_prefers_the_environment(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("GOOGLE_OAUTH_ACCESS_TOKEN", "from-env")
    assert lr.gcp_token("") == "from-env"

    monkeypatch.delenv("GOOGLE_OAUTH_ACCESS_TOKEN")
    assert lr.gcp_token("http://localhost:4588") == "floci-fake-token"


def test_format_table_sorts_and_aligns() -> None:
    table = lr.format_table(
        [lr.Resource("gcp", "pubsub-topic", "b"), lr.Resource("aws", "sqs-queue", "a", "url")]
    )
    lines = table.splitlines()

    assert lines[0].split() == ["CLOUD", "KIND", "NAME", "DETAIL"]
    assert lines[1].startswith("aws") and lines[1].endswith("url")
    assert lr.format_table([]) == "No resources found."


def test_main_prints_json(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    monkeypatch.setattr(lr, "list_gcp", lambda *a, **k: ([lr.Resource("gcp", "k", "lt-x")], ["w"]))

    assert lr.main(["gcp", "--json", "--gcp-endpoint", "http://localhost:4588"]) == 0
    out, err = capsys.readouterr()
    assert json.loads(out) == [{"cloud": "gcp", "kind": "k", "name": "lt-x", "detail": ""}]
    assert "warning: w" in err


def test_main_prints_a_table_for_aws(
    monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
) -> None:
    monkeypatch.setattr(lr, "list_aws", lambda prefix, region: [lr.Resource("aws", "vpc", prefix)])

    assert lr.main(["aws", "--prefix", "lt-stg"]) == 0
    assert "lt-stg" in capsys.readouterr().out
