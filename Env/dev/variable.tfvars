lambda_bucket_name       = "dev-s3-lambda"
artifact_bucket_name     = "dev-artifact-bucket"

lambda_function_name     = "dev-lambda"
lambda_role_name         = "dev-lambda-role"
lambda_handler           = "lambda_function.lambda_handler"
lambda_runtime           = "python3.11"
lambda_s3_key            = "initial-bootstrap.zip"

api_name                 = "dev-http-api"

codebuild_project_name   = "dev-build"
buildspec_file           = "buildspec.yml"

pipeline_name            = "dev-pipeline"
codestar_connection_arn  = "arn:aws:codeconnections:us-east-1:xxxx:connection/xxxxxxxx"
repo_name                = "Vishalldwivedi/test4-arin"
branch                   = "develop"