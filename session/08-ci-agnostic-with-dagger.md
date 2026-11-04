# 8. Lab: CI-agnostic Renovate with Dagger

Five CI templates in [`ci-templates/`](../ci-templates/) do the same thing in five dialects.
Each one is a slightly different snowflake to debug, and you can't run any of them on your laptop.

[Dagger](https://dagger.io) moves the pipeline logic into **code** (here: Python) that runs
in containers. The CI system only has to provide a container runtime and run one command:

```text
             ┌────────────────────────── dagger/ (Python module) ──────────────────────────┐
laptop  ──►  │ RenovateRunner                                                              │
GHA     ──►  │   .base()      → ghcr.io/renovatebot/renovate:<pinned> + cache volume       │
GitLab  ──►  │   .local()     → dry run on a directory (platform=local)                    │
ADO     ──►  │   .validate()  → renovate-config-validator --strict                         │
CodeBuild ►  │   .run()       → real run: token as a Dagger *secret*, never in logs/cache  │
             └─────────────────────────────────────────────────────────────────────────────┘
```

## 8.1 Explore the module

Read [`dagger/src/renovate_runner/main.py`](../dagger/src/renovate_runner/main.py), then:

```bash
dagger functions -m ./dagger                   # list functions
dagger call -m ./dagger version-info           # which Renovate is pinned?
dagger call -m ./dagger validate               # validate ./renovate.json
dagger call -m ./dagger local                  # module 2's dry run, now one command
```

`DefaultPath("/")` means "the root of the git repository the module lives in", so
`validate` and `local` work without arguments.

## 8.2 Exercise: run it for real, from your laptop

```bash
export RENOVATE_TOKEN=$(gh auth token)         # quick & dirty for the lab; CI uses the App
dagger call -m ./dagger run \
  --token=env://RENOVATE_TOKEN \
  --platform=github \
  --repositories=<you>/fixing-broken-windows-with-renovate \
  --dry-run=full
```

`--dry-run=full` does everything except pushing branches and opening PRs.

Questions:

1. Run it twice. Why is the second run faster? (Look for `with_mounted_cache` in `main.py`.)
2. `RENOVATE_TOKEN` is passed as a `dagger.Secret`. What would go wrong with `with_env_variable`?
   (Hint: Dagger caches and traces every operation.)
3. Which **one** line would you change to update Renovate everywhere? Who will change it for you?

## 8.3 Exercise: the same thing in CI

Compare the native and the Dagger templates side by side:

| Native | Dagger |
|--------|--------|
| [github-actions/renovate.yml](../ci-templates/github-actions/renovate.yml) | [dagger/github-actions.yml](../ci-templates/dagger/github-actions.yml) |
| [gitlab-ci/.gitlab-ci.yml](../ci-templates/gitlab-ci/.gitlab-ci.yml) | [dagger/gitlab-ci.yml](../ci-templates/dagger/gitlab-ci.yml) |
| azure-devops / bitbucket / aws-codebuild | [dagger/run-renovate.sh](../ci-templates/dagger/run-renovate.sh): one script for any CI with Docker |

Pick one, copy it into place and get it green.

## 8.4 Discuss: when is Dagger worth it?

| 👍 Use Dagger when | 👎 Skip it when |
|-------------------|-----------------|
| You run Renovate on several CI systems (acquisitions, multi-cloud, on-prem + cloud) | One CI system, and its native template is 20 lines |
| You want to reproduce a CI run **locally**, bit for bit | Your CI can't run containers (some locked-down runners) or privileged Docker |
| You add pre-steps (mint CodeArtifact tokens, fetch Vault secrets) and want them testable | Your team doesn't want another tool to learn |

Renovate itself is already "just a container", so the gain here is moderate. The
pattern pays off more for the *rest* of your pipeline (build, test, publish), and
this module is a small, safe place to try it.
