"""Smoke tests of the deployed stacks - they need the emulators running and
the dev stacks applied:

    make floci-start floci-bootstrap tg-apply ENV=dev
    make test-smoke

They check what a user would check by hand: the resources exist with the
expected names, and the web applications answer through the ALB and Cloud Run.
"""

from __future__ import annotations

import os
import urllib.request

import list_resources as lr
import pytest

pytestmark = pytest.mark.smoke

PREFIX = os.environ.get("SMOKE_PREFIX", "lt-dev")
AWS_REGION = os.environ.get("SMOKE_AWS_REGION", "us-east-1")
GCP_PROJECT = os.environ.get("SMOKE_GCP_PROJECT", "floci-local")
GCP_REGION = os.environ.get("SMOKE_GCP_REGION", "us-central1")
GCP_ENDPOINT = os.environ.get("FLOCI_GCP_ENDPOINT", "http://localhost:4588")
# floci binds the dev ALB listener on this port (live/aws/.../dev/env.hcl).
ALB_URL = os.environ.get("SMOKE_ALB_URL", "http://localhost:8080/")


def http_status(url: str) -> int:
    with urllib.request.urlopen(url, timeout=15) as response:  # noqa: S310 - local URLs
        return int(response.status)


def test_aws_resources_exist() -> None:
    names = {(r.kind, r.name) for r in lr.list_aws(PREFIX, AWS_REGION)}

    assert ("vpc", f"{PREFIX}-vpc") in names
    assert ("load-balancer", f"{PREFIX}-alb") in names
    assert ("ecs-cluster", f"{PREFIX}-ecs") in names
    assert ("rds-instance", f"{PREFIX}-postgres") in names
    assert ("sns-topic", f"{PREFIX}-orders") in names
    assert ("sqs-queue", f"{PREFIX}-orders-billing-dlq") in names


def test_alb_serves_nginx() -> None:
    assert http_status(ALB_URL) == 200


def test_gcp_resources_exist() -> None:
    found, _ = lr.list_gcp(PREFIX, GCP_PROJECT, GCP_REGION, GCP_ENDPOINT)
    names = {(r.kind, r.name) for r in found}

    assert ("gcs-bucket", f"{PREFIX}-{GCP_PROJECT}-assets") in names
    assert ("pubsub-topic", f"{PREFIX}-orders") in names
    assert ("pubsub-subscription", f"{PREFIX}-orders-billing") in names
    assert ("cloud-run-service", f"{PREFIX}-web") in names


def test_cloud_run_serves_nginx() -> None:
    # floci-gcp's invocation proxy (docs/services/cloud-run.md, floci-gcp 0.9.0).
    url = (
        f"{GCP_ENDPOINT}/run/v2/projects/{GCP_PROJECT}/locations/{GCP_REGION}"
        f"/services/{PREFIX}-web/"
    )
    assert http_status(url) == 200
