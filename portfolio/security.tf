resource "aws_secretsmanager_secret" "instagram" {
  name = "${var.prefix}-instagram-token"
}

resource "aws_secretsmanager_secret_version" "instagram" {
  secret_id     = aws_secretsmanager_secret.instagram.id
  secret_string = jsonencode({
    id = "change me"
    key = "change me"
    token = "change me"
  })
}

# Creating a security group for database
resource "aws_security_group" "database-connection" {
  name   = "PostgreSQL Connections"
  vpc_id = var.network.id

  # Allowing traffic in from the same VPC on port 5432
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.network.cidr_block]
    security_groups = [
      var.alb-group.id,
    ]
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

resource "aws_security_group" "node-output" {
  name_prefix = "node-ouput-"
  vpc_id      = var.network.id

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
