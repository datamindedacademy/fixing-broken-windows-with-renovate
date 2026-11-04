# 0. Setup

Do this **before** the session, it takes 10 minutes.

## You need

- A GitHub account (the labs use GitHub; every step has a GitLab / Azure DevOps /
  Bitbucket / CodeBuild equivalent in [`ci-templates/`](../ci-templates/)).
- **Docker** (or Podman) to run Renovate locally. Alternatively Node.js 24+ and `npx`.
- Optional: [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.11
  (or OpenTofu) for module 3/9, and the [Dagger CLI](https://docs.dagger.io/install)
  for module 8.

## Steps

1. Create your own copy of this repository:
   **Use this template → Create a new repository** (public is easiest).
   Name it `fixing-broken-windows-with-renovate`.
2. Clone it:

   ```bash
   git clone https://github.com/<you>/fixing-broken-windows-with-renovate.git
   cd fixing-broken-windows-with-renovate
   ```

3. Pre-pull the Renovate image (≈ 1 GB, don't do this on conference wifi):

   ```bash
   docker pull ghcr.io/renovatebot/renovate:44
   ```

4. Make sure **Issues** are enabled on your repository (Settings → General →
   Features). Renovate's Dependency Dashboard is an issue.
5. **Do not** install the hosted *Mend Renovate* GitHub App on this repo. In this
   session we run Renovate ourselves. Running both gives you duplicate PRs.

✅ Ready when `docker run --rm ghcr.io/renovatebot/renovate:44 renovate --version` prints a version.
