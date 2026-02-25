lambda_bucket_name       = "demo-s3-lambda-vishaldwivedi"
artifact_bucket_name     = "demo-artifact-bucket-vishaldwivedi"

lambda_function_name     = "demo-lambda"
lambda_role_name         = "demo-lambda-role"
lambda_handler           = "lambda_function.lambda_handler"
lambda_runtime           = "python3.11"
lambda_s3_key            = "initial-bootstrap.zip"

api_name                 = "demo-http-api"

codebuild_role_name      = "demo-codebuild-role"
codebuild_policy_name    = "demo-codebuild-policy"
codebuild_policy_file    = "codebuild-policy.json"
buildspec_file           = "buildspec.yml"
codebuild_project_name   = "demo-build"

pipeline_role_name       = "demo-pipeline-role"
pipeline_policy_name     = "demo-pipeline-policy"
pipeline_policy_file     = "pipeline-policy.json"
pipeline_name            = "demo-pipeline"

codestar_connection_arn  = "arn:aws:codeconnections:us-east-1:585768146272:connection/f193f874-c852-4221-a688-ccd7e4875046"
repo_name                = "Vishalldwivedi/test4-arin"
branch                   = "main"