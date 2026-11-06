# Fixing broken windows with Renovate

A hands-on **skill boost session** on keeping repositories up to date with
[Renovate](https://docs.renovatebot.com/), self-hosted in your own CI.

> *Broken windows theory*: one unrepaired window invites more. One outdated
> dependency is easy to bump; two years of them is a migration project.
> Renovate fixes the windows while they are still small.

This repository is both the **course material** and the **patient**. It has
intentionally outdated dependencies across five ecosystems for Renovate to fix.

## What you will learn

| # | Module | Format | Time |
|---|--------|--------|------|
| 0 | [Setup](session/00-setup.md) | prep | 10' |
| 1 | [How Renovate works](session/01-how-renovate-works.md) | talk | 15' |
| 2 | [Lab: a dry run on your laptop](session/02-local-dry-run.md) | lab | 15' |
| 3 | [Lab: self-hosted Renovate in CI, on a schedule](session/03-run-in-ci.md) | lab | 30' |
| 4 | [Lab: taming the noise (schedules, grouping, dashboard)](session/04-taming-the-noise.md) | lab | 20' |
| 5 | [Lab: automerge by semantic version and package name](session/05-automerge.md) | lab | 30' |
| 6 | [Platforms, datasources and private registries](session/06-platforms-and-datasources.md) | talk + demo | 15' |
| 7 | [Lab: custom managers and custom datasources](session/07-custom-managers-and-datasources.md) | lab | 25' |
| 8 | [Lab: CI-agnostic Renovate with Dagger](session/08-ci-agnostic-with-dagger.md) | lab | 15' |
| 9 | [Rolling out to a whole organisation](session/09-rolling-out.md) | talk | 10' |
|   | [Cheat sheet](session/cheatsheet.md) | reference | |
|   | [Facilitator notes](session/facilitator-notes.md) | for trainers | |
|   | [Slide deck](slides/) (Slidev) | for trainers | |

About 3 hours including breaks. Modules 6 to 9 can be shortened to demos for
a 2-hour slot. Solutions are in [`session/solutions/`](session/solutions/).

## Repository map

```text
.
├── backend/  frontend/  charts/  infra/  Dockerfile   ← the patient: outdated on purpose
├── renovate.json                                     ← starting config; you'll grow it in the labs
├── .github/workflows/ci.yml                          ← the tests that make automerge safe
├── session/                                          ← course modules, exercises, solutions
├── slides/                                           ← Slidev deck that follows the modules
├── ci-templates/                                     ← copy-paste Renovate jobs per CI system
│   ├── github-actions/   gitlab-ci/   azure-devops/
│   ├── bitbucket/        aws-codebuild/
│   ├── dagger/                                       ← the same job via the Dagger module
│   └── config.js                                     ← example global (self-hosted) config
├── dagger/                                           ← Dagger module: run Renovate on any CI
└── terraform/                                        ← infra to run Renovate per platform
    ├── github/  gitlab/  azure-devops/  bitbucket/  aws-codebuild/
```

## The patient

| Component | Path | Renovate manager | Outdated dependencies |
|-----------|------|------------------|-----------------------|
| Dockerfile | `Dockerfile` | `dockerfile` (+ a custom manager for `uv`) | `python:3.10.0-slim`, `node:18.0.0-alpine`, `uv==0.1.0` |
| Python backend | `backend/` | `pep621` + `uv` lock file | fastapi, uvicorn, pydantic, requests, sqlalchemy, alembic, psycopg2-binary, python-dotenv |
| TypeScript frontend | `frontend/` | `bun` (npm datasource) | react, next, typescript, eslint, prettier, axios, zod, zustand |
| Helm chart | `charts/postgresql/` | `helmv3` | Bitnami PostgreSQL `12.1.0` |
| Infrastructure | `infra/` | `terraform` (+ a custom datasource for EKS) | AWS provider `5.20.0`, Random provider `3.5.0`, EKS `1.29` |

> `infra/` is the *patient*. `terraform/` is *tooling*: real infrastructure to
> run Renovate. Don't mix them up.

## Quick start

```bash
# 1. Use this repo as a template (or fork it) into your own GitHub account
# 2. See what Renovate would do, without any token or platform:
docker run --rm -v "$PWD:/usr/src/app" -w /usr/src/app \
  ghcr.io/renovatebot/renovate:44 renovate --platform=local
# 3. Continue with session/03-run-in-ci.md to run it for real
```
