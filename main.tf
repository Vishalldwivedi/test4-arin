provider "aws" {
  region = "us-east-1"
}
terraform {
  backend "s3" {
    bucket       = "mybucket-vishaldwivedi-tfstate"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
############################
# S3 BUCKETS
############################

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "demo-s3-lambda-vishaldwivedi"
}

resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "demo-artifact-bucket-vishaldwivedi"
}

resource "aws_lambda_function" "lambda" {
  function_name = "demo-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = "initial-bootstrap.zip"

  lifecycle {
    ignore_changes = [s3_key]
  }
}
# LAMBDA EXECUTION ROLE


resource "aws_iam_role" "lambda_role" {
  name = "demo-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


# API GATEWAY (HTTP API)
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.lambda.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_api" "api" {
  name          = "demo-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}
resource "aws_lambda_permission" "api_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}


# CODEBUILD ROLE


resource "aws_iam_role" "codebuild_role" {
  name = "demo-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "codebuild_policy" {
  name = "demo-codebuild-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # ===== Lambda ZIP bucket =====
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::demo-s3-lambda-vishaldwivedi/*"
      },

      # ===== Artifact bucket (IMPORTANT FIX) =====
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = [
          "arn:aws:s3:::demo-artifact-bucket-vishaldwivedi",
          "arn:aws:s3:::demo-artifact-bucket-vishaldwivedi/*"
        ]
      },

      # ===== Lambda management =====
      {
        Effect = "Allow"
        Action = [
          "lambda:GetFunction",
          "lambda:CreateFunction",
          "lambda:UpdateFunctionCode"
        ]
        Resource = "*"
      },

      # ===== Pass Lambda execution role =====
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = aws_iam_role.lambda_role.arn
      },

      # ===== Logs =====
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}


# CODEBUILD PROJECT


resource "aws_codebuild_project" "project" {
  name         = "demo-build"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
  }

  source {
  type      = "CODEPIPELINE"
  buildspec = "buildspec.yml"
  
}
}


# CODEPIPELINE ROLE


resource "aws_iam_role" "pipeline_role" {
  name = "demo-pipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "codepipeline.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "pipeline_policy" {
  name = "demo-pipeline-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # Artifact bucket access
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::demo-artifact-bucket-vishaldwivedi",
          "arn:aws:s3:::demo-artifact-bucket-vishaldwivedi/*"
        ]
      },

      # Start CodeBuild
      {
        Effect = "Allow"
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]
        Resource = aws_codebuild_project.project.arn
      },

      {
        Effect = "Allow"
        Action = "codestar-connections:UseConnection"
        Resource = "arn:aws:codeconnections:us-east-1:585768146272:connection/866a2381-e631-431e-ba50-fb80aa1d2b39"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "pipeline_attach" {
  role       = aws_iam_role.pipeline_role.name
  policy_arn = aws_iam_policy.pipeline_policy.arn
}


resource "aws_codepipeline" "pipeline" {
  name     = "demo-pipeline"
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifact_bucket.id
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = "arn:aws:codeconnections:us-east-1:585768146272:connection/f193f874-c852-4221-a688-ccd7e4875046"

        FullRepositoryId = "Vishalldwivedi/test4-arin"
        BranchName       = "main"
        DetectChanges    = "true"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.project.name
      }
    }
  }
}

############################
# OUTPUT
############################

output "api_url" {
  value = aws_apigatewayv2_api.api.api_endpoint
}