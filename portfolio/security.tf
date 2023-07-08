# Creating a security group for load balancers
resource "aws_security_group" "entry-point" {
  ingress {
    from_port   = 80 # Allowing traffic in from port 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  ingress {
    from_port   = 443 # Allowing traffic in from port 80
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

resource "aws_security_group" "alb-access" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    # Only allowing traffic in from load balancers security group
    security_groups = [
      aws_security_group.entry-point.id,
    ]
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

resource "aws_secretsmanager_secret" "instagram" {
  name = "${var.prefix}-instagram"
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
  ingress {
    from_port   = 5432 # Allowing traffic in from port 80
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [
      aws_security_group.entry-point.id,
    ]
  }

  ingress {
    from_port   = 5432 # Allowing traffic in from port 80
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [
      "185.153.177.18/32",
      "172.31.0.0/20",
      "172.31.16.0/20",
      "172.31.32.0/20",
    ]
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}
