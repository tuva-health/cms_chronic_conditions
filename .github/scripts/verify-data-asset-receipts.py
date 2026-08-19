#!/usr/bin/env python3
"""Verify package data-asset release receipts before a Git tag is created."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import NoReturn

PROVIDERS = ("s3", "gcs", "azure")
SUPPORTED_SCHEMA_VERSIONS = {1}
TOP_LEVEL_KEYS = {
    "schema_version",
    "package",
    "version",
    "package_commit",
    "files",
}
FILE_KEYS = {"path", "sha256", "bytes", "rows"}
PACKAGE_PATTERN = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
VERSION_PATTERN = re.compile(
    r"^[0-9]+\.[0-9]+\.[0-9]+"
    r"(?:-[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?"
    r"(?:\+[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?$"
)
SHA256_PATTERN = re.compile(r"^[0-9a-f]{64}$")
COMMIT_PATTERN = re.compile(r"^[0-9a-f]{40}$")
SEED_LINE_PATTERN = re.compile(r"^  - seed:\s*([A-Za-z0-9_]+)\s*(?:#.*)?$")
PATH_LINE_PATTERN = re.compile(r"^    path:\s*([A-Za-z0-9_.-]+)\s*(?:#.*)?$")


class ReceiptValidationError(ValueError):
    """A release receipt or its package inventory is invalid."""


def fail(message: str) -> NoReturn:
    raise ReceiptValidationError(message)


def exactly_one(pattern: re.Pattern[str], text: str, label: str) -> str:
    matches = pattern.findall(text)
    if len(matches) != 1:
        fail(f"data_assets.yml must declare exactly one {label}")
    return matches[0]


def expected_assets(catalog_path: Path, expected_package: str) -> list[str]:
    try:
        catalog_text = catalog_path.read_text(encoding="utf-8")
    except OSError as exc:
        fail(f"cannot read {catalog_path}: {exc}")

    schema_version = exactly_one(
        re.compile(r"^schema_version:\s*([0-9]+)\s*(?:#.*)?$", re.MULTILINE),
        catalog_text,
        "schema_version",
    )
    if schema_version != "1":
        fail("data_assets.yml schema_version must be 1")

    package = exactly_one(
        re.compile(r"^package:\s*([a-z0-9-]+)\s*(?:#.*)?$", re.MULTILINE),
        catalog_text,
        "package",
    )
    if package != expected_package:
        fail(
            "data_assets.yml package must be "
            f"{expected_package!r}, found {package!r}"
        )

    asset_headers = re.findall(
        r"^assets:\s*(?:#.*)?$", catalog_text, re.MULTILINE
    )
    if len(asset_headers) != 1:
        fail("data_assets.yml must declare exactly one assets inventory")

    assets: list[tuple[str, str]] = []
    pending_seed: str | None = None
    for line_number, line in enumerate(catalog_text.splitlines(), start=1):
        seed_match = SEED_LINE_PATTERN.fullmatch(line)
        if seed_match:
            if pending_seed is not None:
                fail(
                    f"asset {pending_seed!r} has no path before line {line_number}"
                )
            pending_seed = seed_match.group(1)
            continue

        path_match = PATH_LINE_PATTERN.fullmatch(line)
        if path_match:
            if pending_seed is None:
                fail(f"asset path on line {line_number} has no preceding seed")
            assets.append((pending_seed, path_match.group(1)))
            pending_seed = None

    if pending_seed is not None:
        fail(f"asset {pending_seed!r} has no path")
    if not assets:
        fail("data_assets.yml must declare at least one asset")

    seeds = [seed for seed, _ in assets]
    paths = [path for _, path in assets]
    if len(seeds) != len(set(seeds)):
        fail("data_assets.yml contains duplicate seed names")
    if len(paths) != len(set(paths)):
        fail("data_assets.yml contains duplicate asset paths")

    for seed, path in assets:
        expected_path = f"{seed}.csv.gz"
        if path != expected_path:
            fail(
                f"asset {seed!r} path must be {expected_path!r}, found {path!r}"
            )
        if "/" in path or path in {".", ".."}:
            fail(f"standalone package asset path must be flat: {path!r}")

    if paths != sorted(paths):
        fail("data_assets.yml assets must be sorted by path")
    return paths


def reject_duplicate_keys(pairs: list[tuple[str, object]]) -> dict[str, object]:
    value: dict[str, object] = {}
    for key, item in pairs:
        if key in value:
            raise ValueError(f"duplicate JSON key: {key}")
        value[key] = item
    return value


def reject_json_constant(value: str) -> NoReturn:
    raise ValueError(f"unsupported JSON constant: {value}")


def validate_receipt(
    raw: bytes,
    provider: str,
    expected_package: str,
    expected_version: str,
    expected_commit: str,
    expected_paths: list[str],
) -> None:
    def provider_fail(message: str) -> NoReturn:
        fail(f"{provider} receipt validation failed: {message}")

    try:
        receipt = json.loads(
            raw.decode("utf-8"),
            object_pairs_hook=reject_duplicate_keys,
            parse_constant=reject_json_constant,
        )
    except (UnicodeDecodeError, json.JSONDecodeError, ValueError) as exc:
        provider_fail(f"invalid JSON: {exc}")

    if not isinstance(receipt, dict):
        provider_fail("root must be a JSON object")
    if set(receipt) != TOP_LEVEL_KEYS:
        provider_fail(
            f"top-level keys must be exactly {sorted(TOP_LEVEL_KEYS)}"
        )

    schema_version = receipt["schema_version"]
    if (
        isinstance(schema_version, bool)
        or not isinstance(schema_version, int)
        or schema_version not in SUPPORTED_SCHEMA_VERSIONS
    ):
        provider_fail(f"unsupported schema_version {schema_version!r}")

    if receipt["package"] != expected_package:
        provider_fail(f"package must be {expected_package!r}")
    if receipt["version"] != expected_version:
        provider_fail(f"version must be {expected_version!r}")
    if receipt["package_commit"] != expected_commit:
        provider_fail(f"package_commit must be {expected_commit!r}")

    files = receipt["files"]
    if not isinstance(files, list) or not files:
        provider_fail("files must be a nonempty array")

    paths: list[str] = []
    for index, file_record in enumerate(files):
        label = f"files[{index}]"
        if not isinstance(file_record, dict):
            provider_fail(f"{label} must be a JSON object")
        if set(file_record) != FILE_KEYS:
            provider_fail(f"{label} keys must be exactly {sorted(FILE_KEYS)}")

        object_path = file_record["path"]
        if not isinstance(object_path, str):
            provider_fail(f"{label}.path must be a string")
        paths.append(object_path)

        sha256 = file_record["sha256"]
        if not isinstance(sha256, str) or not SHA256_PATTERN.fullmatch(sha256):
            provider_fail(
                f"{label}.sha256 must be 64 lowercase hex characters"
            )

        for field in ("bytes", "rows"):
            count = file_record[field]
            if (
                isinstance(count, bool)
                or not isinstance(count, int)
                or count <= 0
            ):
                provider_fail(f"{label}.{field} must be a positive integer")

    if paths != sorted(paths):
        provider_fail("files must be sorted by path")
    if len(paths) != len(set(paths)):
        provider_fail("file paths must be unique")
    if paths != expected_paths:
        provider_fail("file paths must exactly match data_assets.yml")


def verify(
    receipt_dir: Path,
    catalog_path: Path,
    expected_package: str,
    expected_version: str,
    expected_commit: str,
) -> None:
    if not PACKAGE_PATTERN.fullmatch(expected_package):
        fail(f"invalid package slug {expected_package!r}")
    if not VERSION_PATTERN.fullmatch(expected_version):
        fail(f"invalid semantic version {expected_version!r}")
    if not COMMIT_PATTERN.fullmatch(expected_commit):
        fail(f"invalid package commit {expected_commit!r}")

    expected_paths = expected_assets(catalog_path, expected_package)
    receipt_bytes: dict[str, bytes] = {}
    for provider in PROVIDERS:
        path = receipt_dir / f"{provider}.json"
        try:
            raw = path.read_bytes()
        except OSError as exc:
            fail(f"cannot read {path}: {exc}")
        receipt_bytes[provider] = raw
        validate_receipt(
            raw,
            provider,
            expected_package,
            expected_version,
            expected_commit,
            expected_paths,
        )
        print(
            f"Validated {provider} receipt for "
            f"{expected_package}@{expected_version}"
        )

    baseline = receipt_bytes["s3"]
    for provider in PROVIDERS[1:]:
        if receipt_bytes[provider] != baseline:
            fail(
                f"{provider} receipt is not byte-identical to the s3 receipt"
            )
    print("Verified byte-identical release receipts across S3, GCS, and Azure")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("receipt_dir", type=Path)
    parser.add_argument("catalog", type=Path)
    parser.add_argument("package")
    parser.add_argument("version")
    parser.add_argument("package_commit")
    args = parser.parse_args()

    try:
        verify(
            args.receipt_dir,
            args.catalog,
            args.package,
            args.version,
            args.package_commit,
        )
    except ReceiptValidationError as exc:
        parser.exit(1, f"{exc}\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
