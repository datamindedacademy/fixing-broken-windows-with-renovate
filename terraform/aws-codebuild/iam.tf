data "aws_iam_policy_document" "codebuild_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild" {
  name               = "${var.name}-codebuild"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    sid       = "Logs"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.renovate.arn}:*"]
  }

  statement {
    sid     = "ReadRenovateSecrets"
    actions = ["secretsmanager:GetSecretValue"]
    resources = [
      aws_secretsmanager_secret.renovate_token.arn,
      aws_secretsmanager_secret.github_com_token.arn,
    ]
  }

  # Uncomment if you mint CodeArtifact tokens in the buildspec (private packages):
  # statement {
  #   actions   = ["codeartifact:GetAuthorizationToken", "sts:GetServiceBearerToken"]
  #   resources = ["*"]
  # }
}

resource "aws_iam_role_policy" "codebuild" {
  name   = "renovate"
  role   = aws_iam_role.codebuild.id
  policy = data.aws_iam_policy_document.codebuild.json
}

data "aws_iam_policy_document" "scheduler_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "scheduler" {
  name               = "${var.name}-scheduler"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume.json
}

data "aws_iam_policy_document" "scheduler" {
  statement {
    actions   = ["codebuild:StartBuild"]
    resources = [aws_codebuild_project.renovate.arn]
  }
}

resource "aws_iam_role_policy" "scheduler" {
  name   = "start-renovate-build"
  role   = aws_iam_role.scheduler.id
  policy = data.aws_iam_policy_document.scheduler.json
}
