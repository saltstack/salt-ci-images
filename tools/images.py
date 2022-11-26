"""
AWS EC2 AMI Related Commands.
"""
from __future__ import annotations

import json
import os
import pathlib
import shutil
import time
from operator import itemgetter

from ptscripts import command_group
from ptscripts import Context
from rich.prompt import Confirm

REPO_ROOT = pathlib.Path(__file__).resolve().parent.parent
PACKER_IMAGES_PATH = REPO_ROOT / "os-images"
TIMESTAMP_UI = " -timestamp-ui" if "CI" in os.environ else ""
PACKER_TMP_DIR = os.path.join(REPO_ROOT, ".tmp", "{}")
AWS_REGION = os.environ.get("AWS_DEFAULT_REGION") or os.environ.get("AWS_REGION") or "us-west-2"

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
        "distro_arch": {
            "help": "The os arch to build.",
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
        "debug": {
            "help": "Pass --debug to packer",
        },
        "skip_create_ami": {
            "help": "Skip pulishing the AMI.",
        },
    },
)
def build_ami(
    ctx: Context,
    distro: str,
    distro_version: str,
    distro_arch: str,
    key_name: str = os.environ.get("RUNNER_NAME"),  # type: ignore[assignment]
    key_path: pathlib.Path = None,
    debug: bool = False,
    region: str = AWS_REGION,
    skip_create_ami: bool = False,
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
        packer_images_path / distro / f"{distro}-{distro_version}-{distro_arch}.pkr.hcl",
        packer_images_path / distro / f"{distro}-{distro_arch}.pkr.hcl",
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
    packer_var_files = [
        packer_images_path / distro / f"{distro}-{distro_version}-{distro_arch}.pkrvars.hcl",
    ]
    for packer_var_file in packer_var_files:
        if packer_var_file.exists():
            var_files.append(packer_var_file.relative_to(REPO_ROOT))
            break
    else:
        ctx.exit(
            1,
            "Could not find a packer vars file. Searched:\n{}".format(
                "\n".join([f" - {path.relative_to(REPO_ROOT)}" for path in packer_var_files]),
            ),
        )

    gh_event_path = os.environ.get("GITHUB_EVENT_PATH") or None
    if gh_event_path is not None:
        gh_event = json.loads(open(gh_event_path).read())
        if "pull_request" in gh_event:
            skip_create_ami = True
        else:
            default_branch = gh_event["repository"]["default_branch"]
            if gh_event["ref"] != f"refs/heads/{default_branch}":
                skip_create_ami = True
    if skip_create_ami:
        ctx.warn("The AMI will not be published. Just testing the build process.")
    ci_build = os.environ.get("RUNNER_NAME") is not None
    command = []
    for var_file in var_files:
        command.append(f"-var-file={var_file}")
    command.extend(
        [
            "-var",
            f"skip_create_ami={str(skip_create_ami).lower()}",
            "-var",
            f"ci_build={str(ci_build).lower()}",
            "-var",
            f"aws_region={region}",
            "-var",
            f"distro_version={distro_version}",
            "-var",
            f"distro_arch={distro_arch}",
            "-var",
            f"ssh_keypair_name={key_name}",
            "-var",
            f"ssh_private_key_file={key_path}",
            str(packer_file),
        ]
    )

    validate_command = [packer, "validate"] + command
    ctx.info(f"Running command: {validate_command}")
    ret = ctx.run(*validate_command, check=False)
    if ret.returncode != 0:
        ctx.exit(ret.returncode)

    build_command = [packer, "build"]
    if debug:
        build_command.append("-debug")
    build_command.extend(command)
    ctx.info(f"Running command: {build_command}")
    ret = ctx.run(*build_command, check=False)
    if ret.returncode != 0:
        ctx.exit(ret.returncode)
    manifest_file = pathlib.Path("manifest.json")
    if ci_build and manifest_file.exists():
        summary_file = os.environ.get("GITHUB_STEP_SUMMARY")
        if summary_file:
            try:
                manifest_data = json.loads(manifest_file.read_text())
                builds = manifest_data["builds"]
                with open(summary_file, "w+", encoding="utf-8") as wfh:
                    wfh.write("| AMI | Region | Name |\n")
                    wfh.write("| :-- | --- | :-- |\n")
                    for build in builds:
                        region, ami = build["artifact_id"].split(":", 1)
                        name = build["custom_data"]["ami_name"]
                        wfh.write(f"| `{ami}` | `{region}` | `{name}` |\n")
            except Exception as exc:
                ctx.error("Failed to generate the build step summary:", exc)
    ctx.exit(0)


@images.command(
    arguments={
        "distro": {
            "help": "The os name to build. Example: ubuntu",
            "choices": os.listdir(PACKER_IMAGES_PATH / "AWS"),
        },
    },
)
def matrix(ctx: Context, distro: str):

    packer_files_dir = PACKER_IMAGES_PATH / "AWS" / distro.lower()
    if not packer_files_dir.exists():
        ctx.exit(1, f"The '{packer_files_dir.relative_to(REPO_ROOT)}' directory does not exit.")

    matrix = {}
    for fname in packer_files_dir.glob("*.pkrvars.hcl"):
        parts = fname.stem.rsplit(".", 1)[0].split("-")
        # Remove the distro name
        parts.pop(0)
        # Add to versions
        version = parts.pop(0)
        matrix.setdefault(version, set())
        # Add the arch
        arch = parts.pop(0)
        matrix[version].add(arch)
        assert not parts

    build_matrix = []
    for version in sorted(matrix):
        for arch in sorted(matrix[version]):
            build_matrix.append(
                {
                    "version": version,
                    "arch": arch,
                }
            )
    print(json.dumps(build_matrix))
    ctx.exit(0)


@images.command
def configs(ctx: Context):
    manifests_path = REPO_ROOT / "manifest"
    if not manifests_path.exists():
        ctx.exit(1, f"The '{manifests_path.relative_to(REPO_ROOT)}' directory does not exist.")

    manifest_files = sorted(list(manifests_path.glob("*.json")))
    if not manifest_files:
        ctx.exit(
            1, f"There are no JSON manifest files in '{manifests_path.relative_to(REPO_ROOT)}'."
        )

    images = {}
    for fname in manifest_files:
        ctx.info(f"Processing {fname.relative_to(REPO_ROOT)} ...")
        data = json.loads(fname.read_text())
        if "builds" not in data:
            ctx.warn("Marformed manifest file. Skipping...")
            continue
        invalid_manifest = False
        for build in data["builds"]:
            if "artifact_id" not in build:
                invalid_manifest = True
                ctx.warn("Marformed manifest file. Skipping...")
                break

            _, ami = build["artifact_id"].split(":")

            if "custom_data" not in build:
                invalid_manifest = True
                ctx.warn("Marformed manifest file. Skipping...")
                break

            custom_data = build["custom_data"]
            slug = custom_data["slug"]
            images[slug] = {
                "ami": ami,
                "ssh_username": custom_data["ssh_username"],
                "description": custom_data["ami_description"],
                "instance_type": custom_data["instance_type"],
                "is_windows": custom_data["is_windows"],
            }
            if slug.startswith("windows"):
                images[slug]["connect_timeout"] = 600

        if invalid_manifest:
            continue

    images_output_file = REPO_ROOT / "golden-images.json"
    ctx.info(f"Generated '{images_output_file.relative_to(REPO_ROOT)}' config:")
    ctx.info(images)
    images_output_file.write_text(json.dumps(images, indent=2))
    ctx.exit(0)


@images.command(
    arguments={
        "ami": {
            "help": "The ami ID to delete.",
        },
        "name": {
            "help": "The ami name filter to use",
        },
        "region": {
            "help": "Which AWS region to search for images.",
        },
        "keep": {
            "help": "When using the name filter, how many images to keep",
        },
        "assume_yes": {
            "help": "Assume yes on destructive questions.",
        },
        "dry_run": {
            "help": "Dry run.",
        },
    },
)
def delete(
    ctx: Context,
    ami: str = None,
    name: str = None,
    region: str = AWS_REGION,
    keep: int = 1,
    assume_yes: bool = False,
    dry_run: bool = False,
):
    if not ami and not name:
        ctx.exit(1, "Please pass one of '--ami/--name'.")
    if ami and name:
        ctx.exit(1, "Please pass only one of '--ami/--name'.")

    try:
        import boto3
    except ImportError:
        ctx.exit(1, "Please install 'boto3'.")

    ec2_client = boto3.client("ec2", region_name=region)
    ec2_resource = boto3.resource("ec2", region_name=region)

    if ami is not None:
        try:
            _delete_ami(ctx, ec2_resource.Image(ami), assume_yes, dry_run, ec2_client, ec2_resource)
        except KeyboardInterrupt:
            ctx.exit(1)
        ctx.exit(0)

    if not name.endswith("*"):
        name += "*"

    filters = [
        {"Name": "name", "Values": [name]},
        {"Name": "state", "Values": ["available"]},
    ]

    response = ec2_client.describe_images(Filters=filters)
    if response["ResponseMetadata"]["HTTPStatusCode"] != 200:
        ctx.error("Failed to get images. Full response:\n", response)
        ctx.exit(1)

    if not response["Images"]:
        exitcode = 0
        if keep == 0:
            exitcode = 1
        ctx.error("No images were returned. Full response:\n", response)
        ctx.exit(exitcode)

    images_listing = sorted(response["Images"], key=itemgetter("Name"))
    if keep:
        images_to_delete = images_listing[: keep * -1]
    else:
        images_to_delete = images_listing

    if not images_to_delete:
        ctx.exit(
            0,
            "Not going to delete {} image(s) that should be kept".format(
                min(len(images_listing), keep)
            ),
        )

    for image_details in images_to_delete:
        try:
            _delete_ami(
                ctx,
                ec2_resource.Image(image_details["ImageId"]),
                assume_yes,
                dry_run,
                ec2_client,
                ec2_resource,
            )
        except KeyboardInterrupt:
            ctx.exit(1)


def _delete_ami(ctx: Context, image, assume_yes: bool, dry_run: bool, ec2_client, ec2_resource):
    import botocore.exceptions

    exitcode = 0
    msg = f"Unregistering {image.id!r}"
    if image.description:
        msg += f", {image.description!r}"
    msg += " ..."
    ctx.warn(msg)
    block_devices = image.block_device_mappings
    try:
        if assume_yes is False:
            msg = f"Unregister {image.id!r}"
            if image.description:
                msg += f", {image.description!r}"
            msg += "?"
            proceed = Confirm.ask(msg, default=False)
            if proceed is False:
                ctx.exit(0, "Not proceeding.")
        image.deregister(DryRun=dry_run)
        ctx.info(f"The AMI {image.id!r} was deregistered.")
    except botocore.exceptions.ClientError as exc:
        if "DryRun flag is set" not in str(exc):
            ctx.error(exc)
            ctx.exit(1)
        else:
            ctx.info(f"The AMI {image.id!r} would have been deregistered.")
    time.sleep(1)
    for block_device in block_devices:
        if "VirtualName" in block_device:
            # Just ignore virtual devices
            continue
        if "Ebs" not in block_device:
            ctx.warn("Skipping non EBS block device with details:\n", block_device)
            continue
        snapshot_id = block_device["Ebs"]["SnapshotId"]
        ctx.warn(f"Deleting snapshot {snapshot_id!r} of {image.id!r}")
        ctx.info("Details:\n", block_device)
        try:
            if assume_yes is False:
                proceed = Confirm.ask(
                    f"Delete snapshot {snapshot_id!r} of {image.id!r}?", default=False
                )
                if proceed is False:
                    ctx.exit(0, "Not proceeding.")
            ec2_client.delete_snapshot(SnapshotId=snapshot_id, DryRun=dry_run)
            ctx.info(f"The snapshot {snapshot_id!r} of {image.id!r} was deleted.")
        except botocore.exceptions.ClientError as exc:
            if "DryRun flag is set" not in str(exc):
                ctx.error(exc)
                ctx.exit(1)
            else:
                ctx.info(f"The snapshot {snapshot_id!r} of {image.id!r} would have been deleted.")
    if exitcode:
        ctx.exit(exitcode)
