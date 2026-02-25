variable "lambda_bucket_name" {
  type        = string
  description = "S3 bucket for Lambda code"
}

variable "artifact_bucket_name" {
  type        = string
  description = "S3 bucket for CodePipeline artifacts"
}
variable "remoteBackend" {
  type        = string
  description = "S3 bucket for CodePipeline artifacts"
}