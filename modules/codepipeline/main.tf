##########################
# CodeBuild Role & Policy
##########################

resource "aws_iam_role" "codebuild_role" {
  name = "${var.codebuild_project_name}-role"

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
  name = "${var.codebuild_project_name}-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource: [
          "arn:aws:s3:::${var.artifact_bucket}",
          "arn:aws:s3:::${var.artifact_bucket}/*"
        ]
      },
      {
        Effect: "Allow",
        Action: [
          "lambda:GetFunction",
          "lambda:CreateFunction",
          "lambda:UpdateFunctionCode"
        ],
        Resource: "*"
      },
      {
        Effect: "Allow",
        Action: "iam:PassRole",
        Resource: "*"
      },
      {
        Effect: "Allow",
        Action: [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource: "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

##########################
# CodeBuild Project
##########################

resource "aws_codebuild_project" "project" {
  name         = var.codebuild_project_name
  service_role = aws_iam_role.codebuild_role.arn

  artifacts { type = "CODEPIPELINE" }

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

##########################
# Pipeline Role & Policy
##########################

resource "aws_iam_role" "pipeline_role" {
  name = "${var.pipeline_name}-role"

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
  name = "${var.pipeline_name}-policy"

  policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
       Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"  
      ]
      Resource = [
        "arn:aws:s3:::${var.artifact_bucket}",
        "arn:aws:s3:::${var.artifact_bucket}/*"
      ]
    },
    {
      Effect   = "Allow"
      Action   = [
        "codebuild:StartBuild",
        "codebuild:BatchGetBuilds"
      ]
      Resource = aws_codebuild_project.project.arn
    },
    {
      Effect   = "Allow"
      Action   = [
        "codestar-connections:UseConnection",
        "codestar-connections:PassConnection"
      ]
      Resource = var.codestar_connection_arn
    }
  ]
})
}

resource "aws_iam_role_policy_attachment" "pipeline_attach" {
  role       = aws_iam_role.pipeline_role.name
  policy_arn = aws_iam_policy.pipeline_policy.arn
}


# CodePipeline


resource "aws_codepipeline" "pipeline" {
  name     = var.pipeline_name
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = var.artifact_bucket
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
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = var.repo_name
        BranchName       = var.branch
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
      configuration   = { ProjectName = aws_codebuild_project.project.name }
    }
  }
}