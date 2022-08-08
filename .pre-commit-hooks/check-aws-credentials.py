#!/usr/bin/env python
# Import Python libs
from __future__ import annotations

import argparse
import json


def check_for_credentials(data, disallowed_keys_with_values):
    errors = set()
    for key, value in data.items():
        if key in disallowed_keys_with_values and value:
            errors.add(key)
        if isinstance(value, dict):
            for error in check_for_credentials(value, disallowed_keys_with_values):
                errors.add(error)
    return errors


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-k",
        "--key",
        dest="keys",
        metavar="KEY",
        action="append",
        default=["aws_access_key", "aws_secret_key"],
    )
    parser.add_argument("files", nargs="+")

    args = parser.parse_args()
    if not args.files:
        parser.exit("No files were passed in")

    collected_errors = {}
    for fname in args.files:
        try:
            with open(fname) as rfh:
                data = json.loads(rfh.read())
        except ValueError:
            parser.exit(f"Failed to JSON load {fname}")
        errors = check_for_credentials(data, args.keys)
        if errors:
            collected_errors[fname] = errors

    if collected_errors:
        for fname, errors in collected_errors.items():
            print(f"Found a populated secret key value in {fname}:")
            for error in errors:
                print(f"  - {error}")
        parser.exit(1)


if __name__ == "__main__":
    main()
