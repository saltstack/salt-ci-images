"""
GitHub Actions CI Utilities.
"""
from __future__ import annotations

import json
import os
import pathlib

from ptscripts import command_group
from ptscripts import Context

ci = command_group(name="ci", help="GitHub CI Utilities", description=__doc__)


@ci.command(
    name="collect-jobs",
    arguments={
        "event_name": {
            "help": "The name of the GitHub event being processed.",
        },
        "changed_files": {
            "help": "JSON payload of changed files from the 'dorny/paths-filter' GitHub action.",
        },
    },
)
def collect_jobs(ctx: Context, event_name: str, changed_files: pathlib.Path):
    """
    Set GH Actions outputs for what should build or not.
    """
    gh_event_path = os.environ.get("GITHUB_EVENT_PATH") or None
    if gh_event_path is None:
        ctx.warn("The 'GITHUB_EVENT_PATH' variable is not set.")
        ctx.exit(1)

    github_output = os.environ.get("GITHUB_OUTPUT")
    if github_output is None:
        ctx.warn("The 'GITHUB_OUTPUT' variable is not set.")
        ctx.exit(1)

    try:
        gh_event = json.loads(open(gh_event_path).read())
    except Exception as exc:
        ctx.error(f"Could not load the GH Event payload from {gh_event_path!r}:\n", exc)
        ctx.exit(1)

    ctx.info("GH Event Payload:")
    ctx.print(gh_event, soft_wrap=True)

    if not changed_files.exists():
        ctx.error(f"The '{changed_files}' file does not exist.")
        ctx.exit(1)
    try:
        changed_files = json.loads(changed_files.read_text())
    except Exception as exc:
        ctx.error(f"Could not load the changed files from:\n{changed_files}:\n", exc)
        ctx.exit(1)

    if event_name == "pull_request":
        ctx.info("Running from a pull request event")
        if gh_event["head"]["repo"]["full_name"] == gh_event["base"]["repo"]["full_name"]:
            # If this is a pull request coming from the same repository, don't run anything
            ctx.info("Pull request is coming from the same repository")
            outputs = {
                "pre-commit": False,
            }
            for key in changed_files:
                if not key.startswith("os-images-"):
                    continue
                outputs[key] = False
            ctx.info("Generated information about what should run:\n", outputs)
            with open(github_output, "a", encoding="utf-8") as wfh:
                wfh.write(f"jobs={json.dumps(outputs)}")
            ctx.exit(0)

        # This is a PR from a forked repository
        ctx.info("Pull request is not comming from the same repository")
        outputs = {
            "pre-commit": True,
        }
        for key, data in changed_files.items():
            if not key.startswith("os-images-"):
                continue
            outputs[key] = data
        ctx.info("Generated information about what should run:\n", outputs)
        with open(github_output, "a", encoding="utf-8") as wfh:
            wfh.write(f"jobs={json.dumps(outputs)}")
        ctx.exit(0)

    # This is a push event
    ctx.info("Running from a push event")
    outputs = {
        "pre-commit": True,
    }
    if gh_event["repository"]["fork"] is True:
        # This is running on a forked repository, just run pre-commit
        ctx.info("The push event is on a forked repository")
        for key in changed_files:
            if not key.startswith("os-images-"):
                continue
            outputs[key] = False
        ctx.info("Generated information about what should run:\n", outputs)
        with open(github_output, "a", encoding="utf-8") as wfh:
            wfh.write(f"jobs={json.dumps(outputs)}")
        ctx.exit(0)

    # Not running on a fork, run everything
    ctx.info("The push event is from the main repository")
    for key, data in changed_files.items():
        if not key.startswith("os-images-"):
            continue
        outputs[key] = data
    ctx.info("Generated information about what should run:\n", outputs)
    with open(github_output, "a", encoding="utf-8") as wfh:
        wfh.write(f"jobs={json.dumps(outputs)}")
    ctx.exit(0)
