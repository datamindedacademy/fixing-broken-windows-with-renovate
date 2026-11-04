"""CI-agnostic Renovate runner.

The same functions run on a laptop, in GitHub Actions, GitLab CI, Azure
Pipelines, Bitbucket Pipelines or AWS CodeBuild: the only thing a CI system
has to provide is a container runtime, the `dagger` CLI and a token.

Examples:

    # Dry-run against the files in the current directory (no token needed)
    dagger call local --source=..

    # Validate a Renovate config file
    dagger call validate --source=.. --config-file=renovate.json

    # Real run against GitHub
    dagger call run --token=env://RENOVATE_TOKEN \
        --platform=github --repositories=my-org/my-repo
"""

from typing import Annotated

import dagger
from dagger import DefaultPath, Doc, dag, function, object_type

# Renovate keeps this line up to date itself, via the regex custom manager in
# renovate.json (see session/07-custom-managers-and-datasources.md).
# renovate: datasource=docker depName=ghcr.io/renovatebot/renovate
RENOVATE_VERSION = "44.210.2"

# The Renovate image runs as the unprivileged `ubuntu` user (uid 12021, gid 0).
RENOVATE_USER = "12021:0"
CACHE_DIR = "/tmp/renovate/cache"


@object_type
class RenovateRunner:
    version: Annotated[str, Doc("Renovate container image tag")] = RENOVATE_VERSION
    image: Annotated[str, Doc("Renovate container image")] = "ghcr.io/renovatebot/renovate"
    renovate_log_level: Annotated[str, Doc("Renovate LOG_LEVEL: debug, info, warn")] = "info"

    @function
    def base(self) -> dagger.Container:
        """The Renovate container with a persistent cache volume mounted."""
        return (
            dag.container()
            .from_(f"{self.image}:{self.version}")
            .with_mounted_cache(
                CACHE_DIR,
                dag.cache_volume(f"renovate-cache-{self.version.split('.')[0]}"),
                owner=RENOVATE_USER,
            )
            .with_env_variable("RENOVATE_CACHE_DIR", CACHE_DIR)
            .with_env_variable("LOG_LEVEL", self.renovate_log_level)
            .with_env_variable("LOG_FORMAT", "pretty")
        )

    @function
    async def version_info(self) -> str:
        """Print the Renovate version inside the image."""
        return await self.base().with_exec(["renovate", "--version"], use_entrypoint=True).stdout()

    @function
    async def validate(
        self,
        source: Annotated[dagger.Directory, Doc("Repository to validate"), DefaultPath("/")],
        config_file: Annotated[
            list[str] | None, Doc("Config file(s) to validate, relative to source")
        ] = None,
        strict: Annotated[bool, Doc("Fail on deprecated/migrated options")] = True,
    ) -> str:
        """Run renovate-config-validator against a repository."""
        args = ["renovate-config-validator"]
        if strict:
            args.append("--strict")
        args.extend(config_file or [])
        return await (
            self.base()
            .with_directory("/usr/src/app", source, owner=RENOVATE_USER)
            .with_workdir("/usr/src/app")
            .with_exec(args, use_entrypoint=True)
            .stdout()
        )

    @function
    async def local(
        self,
        source: Annotated[dagger.Directory, Doc("Repository to scan"), DefaultPath("/")],
        github_com_token: Annotated[
            dagger.Secret | None, Doc("github.com token, avoids rate limits/changelog gaps")
        ] = None,
    ) -> str:
        """Dry-run Renovate against a local directory (platform=local).

        No git hosting platform, no token, no branches: it only shows which
        dependencies Renovate detects and which updates it would propose.
        """
        ctr = (
            self.base()
            .with_directory("/usr/src/app", source, owner=RENOVATE_USER)
            .with_workdir("/usr/src/app")
        )
        if github_com_token:
            ctr = ctr.with_secret_variable("RENOVATE_GITHUB_COM_TOKEN", github_com_token)
        return await ctr.with_exec(
            ["renovate", "--platform=local", "--report-type=logging"], use_entrypoint=True
        ).stdout()

    @function
    async def run(
        self,
        token: Annotated[dagger.Secret, Doc("Token for the git hosting platform")],
        platform: Annotated[
            str, Doc("github, gitlab, azure, bitbucket, bitbucket-server, gitea, ...")
        ] = "github",
        endpoint: Annotated[str, Doc("API endpoint (self-hosted GitLab, Azure DevOps org URL, ...)")] = "",
        repositories: Annotated[list[str] | None, Doc("Repositories to process")] = None,
        autodiscover: Annotated[bool, Doc("Process every repository the token can see")] = False,
        autodiscover_filter: Annotated[
            list[str] | None, Doc("Glob/regex filters for autodiscover")
        ] = None,
        github_com_token: Annotated[
            dagger.Secret | None, Doc("github.com token, for changelogs and rate limits")
        ] = None,
        git_author: Annotated[str, Doc("Commit author")] = "Renovate Bot <renovate@example.com>",
        dry_run: Annotated[str, Doc("'', 'extract', 'lookup' or 'full'")] = "",
        config_file: Annotated[
            dagger.File | None, Doc("Optional self-hosted (global) config.js")
        ] = None,
    ) -> str:
        """Run Renovate against a git hosting platform."""
        if not repositories and not autodiscover:
            raise ValueError("Pass --repositories or --autodiscover")

        ctr = (
            self.base()
            .with_secret_variable("RENOVATE_TOKEN", token)
            .with_env_variable("RENOVATE_PLATFORM", platform)
            .with_env_variable("RENOVATE_GIT_AUTHOR", git_author)
            .with_env_variable("RENOVATE_REPOSITORY_CACHE", "enabled")
        )
        if endpoint:
            ctr = ctr.with_env_variable("RENOVATE_ENDPOINT", endpoint)
        if autodiscover:
            ctr = ctr.with_env_variable("RENOVATE_AUTODISCOVER", "true")
            if autodiscover_filter:
                ctr = ctr.with_env_variable(
                    "RENOVATE_AUTODISCOVER_FILTER", ",".join(autodiscover_filter)
                )
        if github_com_token:
            ctr = ctr.with_secret_variable("RENOVATE_GITHUB_COM_TOKEN", github_com_token)
        if dry_run:
            ctr = ctr.with_env_variable("RENOVATE_DRY_RUN", dry_run)
        if config_file:
            ctr = ctr.with_file(
                "/usr/src/app/config.js", config_file, owner=RENOVATE_USER
            ).with_env_variable("RENOVATE_CONFIG_FILE", "/usr/src/app/config.js")

        return await ctr.with_exec(["renovate", *(repositories or [])], use_entrypoint=True).stdout()
