resource "aws_s3_bucket" "cv-storage" {
  bucket = "${terraform.workspace}-cv"

  tags = {
    Name        = "Curriculum Vitae"
    Environment = terraform.workspace
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "${terraform.workspace}-subnets"
  subnet_ids = var.subnets
}

resource "aws_db_instance" "postgres" {
  db_subnet_group_name        = aws_db_subnet_group.default.name
  allocated_storage           = 20
  max_allocated_storage       = 100
  identifier                  = "${var.prefix}-postgres"
  engine                      = "postgres"
  engine_version              = "14.8"
  instance_class              = "db.t3.micro"
  manage_master_user_password = true
  multi_az                    = false
  username                    = var.postgres.username
  parameter_group_name        = "default.postgres14"
  publicly_accessible         = terraform.workspace == "development"
  skip_final_snapshot         = true
  vpc_security_group_ids = [
    aws_security_group.database-connection.id,
    var.default-security-group.id,
  ]

  depends_on = [
    aws_security_group.database-connection,
  ]
}
