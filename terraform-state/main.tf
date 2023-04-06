resource "aws_s3_bucket" "terraform-state-storage" {
  bucket        = "${var.name}-state"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state-encryption" {
  bucket = aws_s3_bucket.terraform-state-storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "state-version" {
  bucket = aws_s3_bucket.terraform-state-storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform-state-locks" {
  name         = "${var.name}-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
