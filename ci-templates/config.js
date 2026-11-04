// Global ("self-hosted") Renovate configuration.
//
// Renovate has two layers of configuration:
//   1. Global config  - how the BOT behaves: platform, credentials, which repos,
//                       what repositories are allowed to do. Lives with the
//                       runner (this file, CLI flags or RENOVATE_* env vars).
//   2. Repo config    - how dependencies of ONE repository are updated:
//                       renovate.json inside that repository (+ shared presets).
//
// Every option below can also be passed as an env var:
//   gitAuthor -> RENOVATE_GIT_AUTHOR, onboardingConfig -> RENOVATE_ONBOARDING_CONFIG (JSON)
// Env vars win over this file; CLI flags win over env vars.

module.exports = {
  // platform / endpoint / token / repositories are injected by the CI job.

  gitAuthor: 'Renovate Bot <renovate@example.com>',

  // Repositories without a renovate.json get an onboarding PR with this content.
  onboardingConfig: {
    $schema: 'https://docs.renovatebot.com/renovate-schema.json',
    extends: ['config:recommended'],
    // In an organisation you'd rather point at your shared preset:
    // extends: ['github>my-org/renovate-config'],
  },

  // Process only repositories that have been onboarded (merged the onboarding PR)?
  // 'required' (default) | 'optional' | 'ignored'
  requireConfig: 'required',

  // Remember lookups between runs => faster runs, fewer API calls.
  repositoryCache: 'enabled',

  // Never let a single repository take the whole run hostage.
  // (Use with care: a big monorepo can legitimately need more time.)
  // executionTimeout: 15,

  // Credentials for private registries. Prefer env vars over hard-coded secrets.
  hostRules: [
    // Example: a private npm feed on Azure Artifacts
    // {
    //   matchHost: 'pkgs.dev.azure.com',
    //   hostType: 'npm',
    //   token: process.env.AZURE_ARTIFACTS_TOKEN,
    // },
    // Example: an AWS CodeArtifact PyPI repository (token minted in the CI job)
    // {
    //   matchHost: 'my-domain-123456789012.d.codeartifact.eu-west-1.amazonaws.com',
    //   hostType: 'pypi',
    //   username: 'aws',
    //   password: process.env.CODEARTIFACT_AUTH_TOKEN,
    // },
  ],
};
