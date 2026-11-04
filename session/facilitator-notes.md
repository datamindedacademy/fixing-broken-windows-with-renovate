# Facilitator notes

## Before the session

- [ ] Send [00-setup.md](00-setup.md) a few days ahead. The image pull is the long pole.
- [ ] Do the whole lab yourself the day before **with the then-current Renovate version**: Renovate
      releases daily, and version numbers in the expected outputs drift (that's the point of the session).
- [ ] Decide on GitHub Apps: each participant creates one under their own account (simplest), or
      you create one in a training org and share the client ID + key through a secure channel.
- [ ] For module 6's demo: `terraform apply` [terraform/aws-codebuild](../terraform/aws-codebuild) pointing
      at a GitLab project (or any platform other than GitHub) and do one run beforehand so the logs exist.
- [ ] Have a fallback repo where Renovate has already run (PRs, dashboard, automerged PRs) in case
      the network or GitHub rate limits ruin the live run.

## Timing (≈ 3 h)

| Block | Min | Notes |
|-------|-----|-------|
| 0 + 1 | 25 | Ask the room: "who has a dependency they're afraid to update?" Use their answers in module 5. |
| 2 | 15 | The questions are the point, not the command. Discuss 0.x and the Python image. |
| 3 | 30 | Most time goes into creating the GitHub App. Pair people up. |
| break | 10 | |
| 4 | 20 | Let the first run create many PRs *before* this module, so they feel the noise. |
| 5 | 30 | Show the expected-result table only after they've tried. |
| break | 10 | |
| 6 | 15 | Talk + CodeBuild demo. Skip 6.4 for non-Terraform audiences. |
| 7 | 25 | regex101 helps a lot. JSON escaping is the #1 stumbling block. |
| 8 | 15 | Demo if Dagger isn't installed widely; the discussion table matters more than the lab. |
| 9 | 10 | End on the take-aways. |

## Common problems

| Symptom | Cause | Fix |
|---------|-------|-----|
| CI never runs on Renovate PRs | Token is `GITHUB_TOKEN` | Use the GitHub App token |
| `Resource not accessible by integration` | App lacks a permission (often *Workflows* or *Issues*) | Add the permission, then **accept** it in the installation settings |
| Renovate says "onboarding PR" but nothing appears | `requireConfig` + repo without `renovate.json`, PR was closed before | Delete the closed onboarding PR's branch or rename the PR |
| No PRs at all in the run | Run happened outside `schedule` window | Remove `schedule` during the lab or run `workflow_dispatch` inside the window |
| Rate limit errors from github.com | Many participants on one NAT/IP | Make sure the token is set: authenticated calls have 5 000/h per token |
| Lock file artifacts errors on `uv.lock` | Python version in base image vs `requires-python` | Read the artifact error in the PR, it's a good teaching moment |
| Automerge not happening | Required checks missing or ruleset not applied | `terraform apply` in [terraform/github](../terraform/github), check *Settings → Rules* |

## Reset the repo between sessions

```bash
# close all Renovate PRs and delete renovate/* branches
gh pr list --author "app/<your-app-slug>" --json number -q '.[].number' | xargs -n1 gh pr close --delete-branch
gh issue list --search "Dependency Dashboard in:title" --json number -q '.[].number' | xargs -n1 gh issue close
git push origin --delete $(git ls-remote --heads origin 'renovate/*' | awk '{print $2}' | sed 's#refs/heads/##') 2>/dev/null
```
