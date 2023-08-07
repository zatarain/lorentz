# Creating a security group for load balancers
resource "aws_security_group" "entry-point" {
  for_each = toset(local.configuration.sdlc.environments)
  name     = "entry-point-from-world"
  vpc_id   = data.aws_vpc.network.id

  ingress {
    from_port   = 22 # Allowing traffic in from port 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  ingress {
    from_port   = 80 # Allowing traffic in from port 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  ingress {
    from_port   = 443 # Allowing traffic in from port 443
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

  tags = {
    Name = "Entry Point from World"
  }
}

resource "aws_security_group" "alb-access" {
  for_each = toset(local.configuration.sdlc.environments)
  name     = "alb-access"
  vpc_id   = data.aws_vpc.network.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    # Only allowing traffic in from load balancers security group
    security_groups = [
      aws_security_group.entry-point[each.value].id,
    ]
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }

  tags = {
    Name = "ALB Access"
  }
}
