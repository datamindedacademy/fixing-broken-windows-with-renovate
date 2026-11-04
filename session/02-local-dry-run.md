# 2. Lab: a dry run on your laptop

Goal: see what Renovate detects and proposes **before** giving it any token.

The `local` platform runs against the current directory instead of a git host.
It never pushes, never opens PRs: perfect for trying out config.

## 2.1 Run it

```bash
docker run --rm -v "$PWD:/usr/src/app:ro" -w /usr/src/app \
  -e LOG_LEVEL=debug \
  ghcr.io/renovatebot/renovate:44 renovate --platform=local \
  | tee renovate.log
```

<details><summary>Without Docker (Node.js 24+)</summary>

```bash
LOG_LEVEL=debug npx --yes renovate@44 --platform=local | tee renovate.log
```

Without Docker, lock file updates need the package managers (uv, bun, …) on your PATH.
</details>

<details><summary>With Dagger (module 8)</summary>

```bash
dagger call -m ./dagger local
```
</details>

Look for these log lines:

- `Dependency extraction complete`: how many dependencies per **manager**.
- `packageFiles with updates` (debug): every dependency with its proposed **updates**.

Scrolling through debug logs gets old fast. Ask for a JSON report instead and summarise it
with `jq`:

```bash
mkdir -p out && chmod 777 out   # the container runs as an unprivileged user
docker run --rm -v "$PWD:/usr/src/app:ro" -v "$PWD/out:/out" -w /usr/src/app \
  ghcr.io/renovatebot/renovate:44 renovate --platform=local \
  --report-type=file --report-path=/out/report.json

jq -r '.repositories[].packageFiles | to_entries[] | .key as $m | .value[] | .packageFile as $f
       | .deps[] | [$m, $f, .depName, .currentValue,
         ([.updates[]? | "\(.updateType)→\(.newVersion // .newValue)"] | join(" "))] | @tsv' \
  out/report.json
```

```text
bun     frontend/package.json   react   18.0.0  minor→18.3.1 major→19.3.1
bun     frontend/package.json   next    13.0.0  minor→13.5.11 major→16.4.5
bun     frontend/package.json   axios   0.27.0  minor→0.35.0 major→1.21.0
...
```

## 2.2 Questions

Answer these from the output. Discuss with your neighbour.

1. Which **managers** did Renovate use? Which file did each one read?
2. `axios 0.27.0 → 0.35.0` is labelled **minor**. Is that safe to merge blindly? (Hint: semver §4.)
3. `python 3.10.0-slim → 3.15.2-slim` is labelled **minor** too. Why does Renovate think so,
   and would you treat it as minor?
4. The `Dockerfile` installs `uv==0.1.0`. Did Renovate find it? Why (not)?
5. Does Renovate propose to update `infra/variables.tf` (the EKS version)? Why (not)?
6. Why is there no update for the `hashicorp/terraform` required version without a GitHub token?

<details><summary>Answers</summary>

1. `bun` (frontend/package.json + bun.lock), `pep621` (backend/pyproject.toml, uv.lock is updated
   alongside), `dockerfile`, `helmv3` (Chart.yaml), `terraform` (infra/main.tf).
2. No. Before 1.0 *anything may change*. Renovate's `npm`/`semver` versioning still calls
   0.27 → 0.35 a "minor". Module 5 adds a rule for this.
3. Docker tags use `docker` versioning: `3.10.0 → 3.15.2` is a minor in the tag. For Python
   the language, a minor version can drop deprecated APIs and break binary wheels (try installing
   `psycopg2-binary==2.9.5` on Python 3.13). Module 5 adds a rule.
4. No. `RUN pip install uv==0.1.0` is a shell command, no built-in manager parses that.
   Module 7 fixes this with a custom manager.
5. No. A string in a Terraform variable isn't a dependency Renovate knows about, and EKS
   versions aren't in any built-in datasource. Module 7 adds a custom datasource.
6. The Terraform CLI versions are looked up from GitHub releases, which needs a github.com
   token (`RENOVATE_GITHUB_COM_TOKEN`). Same for release notes. In CI you'll always want one.
</details>

## 2.3 Validate your config

Every time you change `renovate.json`, validate it:

```bash
docker run --rm -v "$PWD:/usr/src/app:ro" -w /usr/src/app ghcr.io/renovatebot/renovate:44 \
  renovate-config-validator --strict
```

`--strict` also fails on deprecated options that Renovate would silently migrate.
The `renovate-config` job in [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) does the same on every PR.
