data "aws_iam_policy_document" "runner" {
	provider = aws.root
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::016474493108:role/cv-task-runner"]
    }
  }
}

data "aws_iam_policy_document" "executor" {
	provider = aws.root
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::016474493108:role/cv-task-command-executor"]
    }
  }
}

resource "aws_iam_role" "task-runner" {
  for_each = toset(local.configuration.load_balancers)

  name               = "task-runner"
  assume_role_policy = data.aws_iam_policy_document.runner.json
}

resource "aws_iam_role_policy_attachment" "task-runner-policy" {
  for_each = toset(local.configuration.load_balancers)

  role       = aws_iam_role.task-runner[each.value].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task-command-executor" {
  for_each = toset(local.configuration.load_balancers)

  name               = "task-command-executor"
  assume_role_policy = data.aws_iam_policy_document.executor.json
}

resource "aws_iam_role_policy_attachment" "task-command-executor-policy" {
  for_each = toset(local.configuration.load_balancers)

  role       = aws_iam_role.task-command-executor[each.value].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_role" "task-runner" {
	provider = aws.root
	name     = "task-runner"
}

data "aws_iam_role" "task-command-executor" {
	provider = aws.root
	name     = "task-command-executor"
}
