#!/usr/bin/env bash
# CI-agnostic entrypoint: works anywhere with Docker + the dagger CLI
# (Azure Pipelines, Bitbucket Pipelines with the docker service, CodeBuild in
# privileged mode, Jenkins, your laptop, ...).
#
#   RENOVATE_TOKEN=... RENOVATE_PLATFORM=gitlab RENOVATE_ENDPOINT=https://gitlab.example.com/api/v4 \
#   RENOVATE_REPOSITORIES="group/a group/b" ./ci-templates/dagger/run-renovate.sh
set -euo pipefail

: "${RENOVATE_TOKEN:?RENOVATE_TOKEN is required}"
RENOVATE_PLATFORM="${RENOVATE_PLATFORM:-github}"
REPO_ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"

args=(run --token=env://RENOVATE_TOKEN --platform="$RENOVATE_PLATFORM")
[[ -n "${RENOVATE_ENDPOINT:-}" ]] && args+=(--endpoint="$RENOVATE_ENDPOINT")
[[ -n "${RENOVATE_GITHUB_COM_TOKEN:-}" ]] && args+=(--github-com-token=env://RENOVATE_GITHUB_COM_TOKEN)
if [[ -n "${RENOVATE_REPOSITORIES:-}" ]]; then
  for repo in $RENOVATE_REPOSITORIES; do args+=(--repositories="$repo"); done
else
  args+=(--autodiscover)
  [[ -n "${RENOVATE_AUTODISCOVER_FILTER:-}" ]] && args+=(--autodiscover-filter="$RENOVATE_AUTODISCOVER_FILTER")
fi
[[ -n "${RENOVATE_DRY_RUN:-}" ]] && args+=(--dry-run="$RENOVATE_DRY_RUN")

exec dagger call -m "$REPO_ROOT/dagger" --renovate-log-level="${LOG_LEVEL:-info}" "${args[@]}"
