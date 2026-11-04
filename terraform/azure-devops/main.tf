resource "azuredevops_project" "this" {
  name               = var.project_name
  description        = "Fixing broken windows with Renovate"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Basic" # has the "Issue" work item type Renovate uses by default

  features = {
    boards       = "enabled" # Renovate creates its Dependency Dashboard as a work item
    repositories = "enabled"
    pipelines    = "enabled"
  }
}

# Import the workshop repo (outdated dependencies included) into Azure Repos.
resource "azuredevops_git_repository" "demo" {
  project_id     = azuredevops_project.this.id
  name           = "fixing-broken-windows-with-renovate"
  default_branch = "refs/heads/main"

  initialization {
    init_type   = "Import"
    source_type = "Git"
    source_url  = var.source_repository_url
  }

  lifecycle {
    ignore_changes = [initialization]
  }
}

# --- Secrets for the pipeline -----------------------------------------------

resource "azuredevops_variable_group" "renovate" {
  project_id   = azuredevops_project.this.id
  name         = "renovate"
  description  = "Secrets for the Renovate pipeline"
  allow_access = true # all pipelines in the project may use it

  variable {
    name         = "RENOVATE_GITHUB_COM_TOKEN"
    is_secret    = true
    secret_value = var.github_com_token
  }
}

# --- The Renovate pipeline ---------------------------------------------------
# The schedule itself lives in the YAML (`schedules:`), next to the job.

resource "azuredevops_build_definition" "renovate" {
  project_id = azuredevops_project.this.id
  name       = "renovate"
  path       = "\\"

  # Use the project-scoped identity "<project> Build Service (<org>)" for
  # $(System.AccessToken), so the permissions below apply.
  job_authorization_scope = "project"

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.demo.id
    branch_name = azuredevops_git_repository.demo.default_branch
    yml_path    = "ci-templates/azure-devops/azure-pipelines.yml"
  }

  ci_trigger {
    use_yaml = true
  }

  variable_groups = [azuredevops_variable_group.renovate.id]
}

# --- Let $(System.AccessToken) push branches and open PRs --------------------

data "azuredevops_identity_user" "build_service" {
  name          = "${azuredevops_project.this.name} Build Service (${var.organization})"
  search_filter = "DisplayName"
}

resource "azuredevops_git_permissions" "build_service" {
  project_id    = azuredevops_project.this.id
  repository_id = azuredevops_git_repository.demo.id
  principal     = data.azuredevops_identity_user.build_service.descriptor

  permissions = {
    GenericRead           = "Allow"
    GenericContribute     = "Allow"
    CreateBranch          = "Allow"
    PullRequestContribute = "Allow"
  }
}
