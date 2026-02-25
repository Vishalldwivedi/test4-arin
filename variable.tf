# S3
variable "lambda_bucket_name" { type = string }
variable "artifact_bucket_name" { type = string }

# Lambda
variable "lambda_function_name" { type = string }
variable "lambda_role_name" { type = string }
variable "lambda_handler" { type = string }
variable "lambda_runtime" { type = string }
variable "lambda_s3_key" { type = string }

# API Gateway
variable "api_name" { type = string }

# CodeBuild
variable "codebuild_project_name" { type = string }
variable "buildspec_file" { type = string }

# CodePipeline
variable "pipeline_name" { type = string }
variable "codestar_connection_arn" { type = string }
variable "repo_name" { type = string }
variable "branch" { type = string }