"""
AWS EC2 AMI Related Commands.
"""
from __future__ import annotations

import os
import pathlib
import shutil

from ptscripts import command_group
from ptscripts import Context

REPO_ROOT = pathlib.Path(__file__).resolve().parent.parent
PACKER_IMAGES_PATH = REPO_ROOT / "os-images"
TIMESTAMP_UI = " -timestamp-ui" if "CI" in os.environ else ""
PACKER_TMP_DIR = os.path.join(REPO_ROOT, ".tmp", "{}")

images = command_group(name="images", help="AWS EC2 AMI Commands", description=__doc__)


@images.command(
    name="build-ami",
    arguments={
        "distro": {
            "help": "The os name to build. Example: ubuntu",
            "choices": os.listdir(PACKER_IMAGES_PATH / "AWS"),
        },
        "distro_version": {
            "help": "The os version to build. Example: 22.04",
        },
        "arch": {
            "help": "The os arch to build. One of 'x86_64', 'aarch64'.",
            "choices": ["x86_64", "arm64"],
        },
        "region": {
            "help": "Which AWS region to build image and publish image.",
        },
        "key_name": {
            "help": "The SSH key name.",
        },
        "key_path": {
            "help": "The path to the SSH private key.",
        },
        "build_type": {
            "help": "The type of image build. Choices: ['ci', 'ci-staging'].",
            "choices": ["ci", "ci-staging"],
        },
        "debug": {
            "help": "Pass --debug to packer",
        },
    },
)
def build_ami(
    ctx: Context,
    distro: str,
    distro_version: str,
    arch: str = "x86_64",
    key_name: str = os.environ.get("RUNNER_NAME"),  # type: ignore[assignment]
    key_path: pathlib.Path = None,
    debug: bool = False,
    build_type: str = "ci",
    region: str = "eu-central-1",
):
    """
    Build EC2 AMIs.
    """
    packer = shutil.which("packer")
    if not packer:
        ctx.exit(1, "The 'packer' binary could not be found")
    if key_name is None:
        ctx.exit(1, "We need a key name to spin a VM")
    if key_path is None:
        searched_paths = []
        for name in ("rsa", "ed25519"):
            path = pathlib.Path.home() / ".ssh" / f"id_{name}"
            searched_paths.append(path)
            if path.exists():
                key_path = path
                break
        else:
            ctx.exit(
                1,
                "Clould not find the ssh private key file. Searched:\n{}".format(
                    "\n".join([f" - {path}" for path in searched_paths])
                ),
            )

    packer_images_path = PACKER_IMAGES_PATH / "AWS"
    packer_files = [
        packer_images_path / distro / f"{distro}-{distro_version}-{arch}.pkr.hcl",
        packer_images_path / distro / f"{distro}-{distro_version}.pkr.hcl",
        packer_images_path / distro / f"{distro}-{arch}.pkr.hcl",
        packer_images_path / distro / f"{distro}.pkr.hcl",
    ]
    for packer_file in packer_files:
        if packer_file.exists():
            break
    else:
        ctx.exit(
            1,
            "Could not find a packer file to use for '{}'. Searched:\n{}".format(
                distro,
                "\n".join([f" - {path.relative_to(REPO_ROOT)}" for path in packer_files]),
            ),
        )

    var_files = []
    required_packer_var_files = [
        packer_images_path / distro / f"{distro}-{distro_version}-{arch}.pkrvars.hcl",
        packer_images_path / distro / f"{distro}-{distro_version}.pkrvars.hcl",
        packer_images_path / distro / f"{distro}-{arch}.pkrvars.hcl",
    ]
    for packer_var_file in required_packer_var_files:
        if packer_var_file.exists():
            var_files.append(packer_var_file.relative_to(REPO_ROOT))
            break
    else:
        ctx.exit(
            1,
            "Could not find a '{}' specific packer vars file. Searched:\n{}".format(
                arch,
                "\n".join(
                    [f" - {path.relative_to(REPO_ROOT)}" for path in required_packer_var_files]
                ),
            ),
        )
    packer_var_files = [
        packer_images_path / distro / f"{distro}-{distro_version}.pkrvars.hcl",
        packer_images_path / distro / f"{distro}.pkrvars.hcl",
    ]
    for packer_var_file in packer_var_files:
        if packer_var_file.exists():
            var_files.append(packer_var_file.relative_to(REPO_ROOT))

    command = []
    if "CI" in os.environ:
        command.append("-timestamp-ui")
    if debug:
        command.append("-debug")
    for var_file in var_files:
        command.append(f"-var-file={var_file}")
    command.extend(
        [
            "-var",
            f"ci_build={str(os.environ.get('RUNNER_NAME') is not None).lower()}",
            "-var",
            f"aws_region={region}",
            "-var",
            f"distro_version={distro_version}",
            "-var",
            f"distro_arch={arch}",
            "-var",
            f"distro_slug={distro}-{distro_version}-{arch}",
            "-var",
            f"ssh_keypair_name={key_name}",
            "-var",
            f"ssh_private_key_file={key_path}",
            str(packer_file),
        ]
    )
    build_command = [packer, "build"] + command
    validate_command = [packer, "validate"] + command
    ctx.info(f"Running command: {validate_command}")
    ret = ctx.run(*validate_command, check=False)
    if ret.returncode != 0:
        ctx.exit(ret.returncode)
    ctx.info(f"Running command: {build_command}")
    ret = ctx.run(*build_command, check=False)
    if ret.returncode != 0:
        ctx.exit(ret.returncode)
    ctx.exit(0)
