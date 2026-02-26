lambda_bucket_name       = "prod-s3-lambda-vishalldwivedi"
artifact_bucket_name     = "prod-artifact-bucket-vishalldwivedi"

lambda_function_name     = "prod-lambda"
lambda_role_name         = "prod-lambda-role"
lambda_handler           = "lambda_function.lambda_handler"
lambda_runtime           = "python3.11"
lambda_s3_key            = "initial-bootstrap.zip"

api_name             = "prod-http-api"

codebuild_project_name   = "prod-build"
buildspec_file           = "buildspec.yml"

pipeline_name            = "prod-pipeline"
codestar_connection_arn  = "arn:aws:codeconnections:us-east-1:585768146272:connection/866a2381-e631-431e-ba50-fb80aa1d2b39"
repo_name                = "Vishalldwivedi/test4-arin"
branch                   = "main"
remoteBackend            = "myRemoteBackendVishalDwivediBucket"