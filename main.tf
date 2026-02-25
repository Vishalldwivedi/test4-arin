module "s3" {
  source               = "./modules/s3"
  lambda_bucket_name   = var.lambda_bucket_name
  artifact_bucket_name = var.artifact_bucket_name
}

module "lambda" {
  source               = "./modules/lambda"
  lambda_function_name = var.lambda_function_name
  lambda_role_name     = var.lambda_role_name
  lambda_handler       = var.lambda_handler
  lambda_runtime       = var.lambda_runtime
  lambda_bucket        = module.s3.lambda_bucket_id
  lambda_s3_key        = var.lambda_s3_key
}

module "apigateway" {
  source               = "./modules/apigateway"
  api_name             = var.api_name
  lambda_arn           = module.lambda.lambda_function_arn
  lambda_function_name = var.lambda_function_name
}

module "codepipeline" {
  source                  = "./modules/codepipeline"
  artifact_bucket         = module.s3.artifact_bucket_id
  codestar_connection_arn = var.codestar_connection_arn
  repo_name               = var.repo_name
  branch                  = var.branch
  codebuild_project_name  = var.codebuild_project_name
  pipeline_name           = var.pipeline_name
}
#terraform apply -var-file="dev.tfvars"
#terraform apply -var-file="prod.tfvars"