#!/usr/bin/env python
from __future__ import annotations

import argparse
import shutil
import subprocess


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("files", nargs="+")

    args = parser.parse_args()
    if not args.files:
        parser.exit(1, "No files were passed in")

    packer = shutil.which("packer")
    if not packer:
        parser.exit(1, "The 'packer' binary could not be found in path")

    collected_errors = {}
    exitcode = 0
    for fname in args.files:
        ret = subprocess.run(
            [packer, "fmt", "-write=true", fname],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            shell=False,
            check=False,
            text=True,
        )
        if ret.returncode:
            exitcode += 1
            collected_errors[fname] = ret.stdout

    if collected_errors:
        for fname, error in collected_errors.items():
            print(f"Failed to format '{fname}':")
            print(error)
    parser.exit(exitcode)


if __name__ == "__main__":
    main()
