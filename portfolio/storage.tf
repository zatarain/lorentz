resource aws_s3_bucket "cv-storage" {
	bucket = "${terraform.workspace}-cv"

	tags = {
		Name = "Curriculum Vitae"
		Environment = terraform.workspace
	}
}
