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

data "aws_iam_policy_document" "control-channel" {
	statement {
		effect = "Allow"
		actions = [
			"ssmmessages:CreateControlChannel",
			"ssmmessages:CreateDataChannel",
			"ssmmessages:OpenControlChannel",
			"ssmmessages:OpenDataChannel",
		]
		resources = ["*"]
	}
}

resource "aws_iam_policy" "data-control-channel" {
	name        = "control-channel"
	description = "Policy to allow control a task container"
	policy      = data.aws_iam_policy_document.control-channel.json
}

resource "aws_iam_role_policy_attachment" "data-control-channel" {
  role       = aws_iam_role.task-runner.name
  policy_arn = aws_iam_policy.data-control-channel.arn
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

data "aws_iam_policy_document" "ecs-worker" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs-worker" {
  name_prefix        = "ecs-worker-"
  assume_role_policy = data.aws_iam_policy_document.ecs-worker.json
}

resource "aws_iam_role_policy_attachment" "ecs-worker-policy" {
  role       = aws_iam_role.ecs-worker.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
