resource aws_s3_bucket "cv-storage" {
	bucket = "${terraform.workspace}-cv"

	tags = {
		Name = "Curriculum Vitae"
		Environment = terraform.workspace
	}
}
data "aws_iam_policy_document" "s3-access" {
  statement {
    sid = "CurriculumAPIS3"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
    ]

    resources = [aws_s3_bucket.cv-storage.arn]
  }
}

resource "aws_iam_policy" "s3-access" {
  name   = "CurriculumS3Access"
  policy = data.aws_iam_policy_document.s3-access.json
}
