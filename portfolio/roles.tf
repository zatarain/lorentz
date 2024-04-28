resource "aws_iam_role" "task-runner" {
  name               = "${var.prefix}-task-runner"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "task-runner-policy" {
  role       = aws_iam_role.task-runner.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task-command-executor" {
  name               = "${var.prefix}-task-command-executor"
  assume_role_policy = data.aws_iam_policy_document.command-executor.json
}

data "aws_iam_policy_document" "command-executor" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "secrets-manager-access" {
  statement {
    actions = ["secretsmanager:GetSecretValue"]
    resources = [
      aws_secretsmanager_secret.instagram.arn,
      local.postgres_user.secret_arn,
    ]
  }
}

resource "aws_iam_policy" "secrets-access" {
  name   = "PortfolioSecretsAccess"
  path   = "/"
  policy = data.aws_iam_policy_document.secrets-manager-access.json
}

resource "aws_iam_role_policy_attachment" "task-command-executor-policy" {
  role       = aws_iam_role.task-command-executor.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "task-executor-access-to-s3" {
  role       = aws_iam_role.task-command-executor.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "task-executor-access-to-secrets" {
  role       = aws_iam_role.task-runner.name
  policy_arn = aws_iam_policy.secrets-access.arn
}
