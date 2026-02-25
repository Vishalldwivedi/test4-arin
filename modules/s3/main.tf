resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.lambda_bucket_name
}

resource "aws_s3_bucket" "artifact_bucket" {
  bucket = var.artifact_bucket_name
}