variable "artifact_bucket" {
  type        = string
  description = "S3 bucket name for storing pipeline artifacts"
}

variable "codestar_connection_arn" {
  type        = string
  description = "ARN of the CodeStar connection"
}

variable "repo_name" {
  type        = string
  description = "CodeStar repo full name"
}

variable "branch" {
  type        = string
  description = "Branch name to build"
}

variable "codebuild_project_name" {
  type        = string
  description = "CodeBuild project name"
}

variable "pipeline_name" {
  type        = string
  description = "CodePipeline name"
}