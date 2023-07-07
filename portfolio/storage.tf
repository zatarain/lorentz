resource aws_s3_bucket "cv-storage" {
	bucket = "${terraform.workspace}-cv"

	tags = {
		Name = "Curriculum Vitae"
		Environment = terraform.workspace
	}
}

resource "aws_db_instance" "postgres" {
  allocated_storage           = 20
	max_allocated_storage				= 100
  identifier                  = "${var.prefix}-${var.name}"
	engine                      = "postgres"
  engine_version              = "14.7"
  instance_class              = "db.t3.micro"
  manage_master_user_password = true
	multi_az  									= false
  username                    = var.postgres.username
  parameter_group_name        = "default.postgres14"
	publicly_accessible					= terraform.workspace == "development"
	skip_final_snapshot         = true
}
