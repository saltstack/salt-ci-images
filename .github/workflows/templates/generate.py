#!/usr/bin/env python
from __future__ import annotations

import json
import pathlib
import sys

TEMPLATES_PATH = pathlib.Path(__file__).resolve().parent
REPO_ROOT = TEMPLATES_PATH.parent.parent.parent
WORKFLOWS_PATH = REPO_ROOT / ".github" / "workflows"

DISTRO_DISPLAY_NAMES = {
    "almalinux": "AlmaLinux",
    "arch": "Arch Linux",
    "centos-stream": "CentOS Stream",
    "oracle-linux": "Oracle Linux",
    "rocky-linux": "Rocky Linux",
    "macos": "macOS",
    "freebsd": "FreeBSD",
    "openbsd": "OpenBSD",
}

TIMEOUT_DEFAULT = 30
TIMEOUT_OVERRIDES = {
    "gentoo": 90,
}

EXCLUDES = {
    "debian": [
        # Not building ARM for Debian 10
        {"os-arch": "arm64", "os-version": "10"},
        # There's only a parallels image, no virtualbox
        {"os-arch": "arm64", "os-version": "11"},
    ],
    "ubuntu": [
        # Not building ARM64 for 18.04
        {"os-arch": "arm64", "os-version": "18.04"},
        # There are no virtualbox boxes
        {"os-arch": "arm64", "os-version": "20.04"},
        {"os-arch": "arm64", "os-version": "22.04"},
    ],
}


TEMPLATE = """
  {distro}:
    name: {display_name}
    uses: {uses}
    needs:
      - install-packer-plugins
    with:
      os-name: {distro}
      os-arch-matrix: '{os_arch_matrix}'
      os-version-matrix: '{os_version_matrix}'
      exclude-matrix: '{exclude_matrix}'
      packer-version: {packer_version}
    secrets:
      VAGRANT_CLOUD_TOKEN: ${{{{ secrets.VAGRANT_CLOUD_TOKEN }}}}
"""


def generate_test_jobs():
    test_jobs = ""
    needs = ["install-packer-plugins"]
    packer_version = "1.8.2"
    packer_vagrant_plugin_version = "v1.0.3"

    for distro_path in sorted(REPO_ROOT.joinpath("os-images", "Vagrant").glob("*")):
        distro = distro_path.name
        print(
            f"Processing {DISTRO_DISPLAY_NAMES.get(distro, distro.title())}...",
            file=sys.stderr,
            flush=True,
        )
        test_jobs += "\n"
        runs_on = "macos-12"
        runs_on = f"\n      runs-on: {runs_on}"
        uses = "./.github/workflows/golden-vagrant-image.yml"
        arches = {"amd64"}
        versions = set()
        for file in sorted(distro_path.glob("*.pkrvars*")):
            arch = None
            version = file.stem.replace(f"{distro}-", "").rsplit(".", 1)[0]
            if "-" in version:
                version, arch = version.split("-")
            if arch is not None:
                arches.add(arch)
            versions.add(version)

        excludes = EXCLUDES.get(distro, [])
        timeout_minutes = TIMEOUT_OVERRIDES.get(distro, TIMEOUT_DEFAULT)

        needs.append(distro)
        test_jobs += TEMPLATE.format(
            distro=distro,
            uses=uses,
            os_arch_matrix=json.dumps(sorted(arches)),
            os_version_matrix=json.dumps(sorted(versions)),
            exclude_matrix=json.dumps(excludes),
            display_name=DISTRO_DISPLAY_NAMES.get(distro, distro.title()),
            timeout_minutes=timeout_minutes,
            packer_version=packer_version,
        )

    ci_src_workflow = TEMPLATES_PATH / "ci.yml"
    ci_tail_src_workflow = TEMPLATES_PATH / "ci-tail.yml"
    ci_dst_workflow = WORKFLOWS_PATH / "ci.yml"
    ci_workflow_contents = (
        ci_src_workflow.read_text()
        .replace("{PACKER_VERSION}", packer_version)
        .replace("{PACKER_VAGRANT_PLUGIN_VERSION}", packer_vagrant_plugin_version)
        + test_jobs
        + "\n"
    )
    ci_workflow_contents += ci_tail_src_workflow.read_text().format(
        needs="\n".join([f"      - {need}" for need in needs]).lstrip()
    )
    ci_dst_workflow.write_text(ci_workflow_contents)


if __name__ == "__main__":
    generate_test_jobs()
