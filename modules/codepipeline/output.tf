output "codebuild_project_arn" {
  value = aws_codebuild_project.project.arn
}

output "pipeline_arn" {
  value = aws_codepipeline.pipeline.arn
}