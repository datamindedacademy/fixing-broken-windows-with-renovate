# Dagger module: `renovate-runner`

Run Renovate the same way on a laptop and on any CI system that can run containers.
Used in [module 8](../session/08-ci-agnostic-with-dagger.md).

```bash
dagger functions                       # from this directory, or add -m ./dagger from the repo root
dagger call version-info
dagger call validate                   # renovate-config-validator --strict on the repo root
dagger call validate --config-file=session/solutions/renovate.json
dagger call local                      # dry run with platform=local, no token needed
dagger call run --token=env://RENOVATE_TOKEN --platform=github --repositories=org/repo --dry-run=full
dagger call --version=44.210.2 --renovate-log-level=debug run ...   # constructor args go first
```

| Function | Does |
|----------|------|
| `base` | Renovate container + persistent cache volume (returns a `Container`: try `dagger call base terminal`) |
| `version-info` | `renovate --version` |
| `validate` | `renovate-config-validator` on files from the repo |
| `local` | dry run on the repo with `--platform=local` |
| `run` | real run against `github`, `gitlab`, `azure`, `bitbucket`, … with the token as a Dagger secret |

The pinned Renovate version (`RENOVATE_VERSION` in [main.py](src/renovate_runner/main.py))
is kept up to date by Renovate itself, through the annotated-comment custom manager.

The `sdk/` directory is generated: run `dagger develop` after cloning to get editor completion.
