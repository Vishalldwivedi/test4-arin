# I am the Lambda function, I need a badge (IAM Role) to interact with AWS services.
#Without the role → Lambda cannot run.
#Without the policy → Lambda runs but cannot log or access AWS services.
#IAM Role → the badge Lambda wears
#Policy → what the badge allows Lambda to do (log, read S3, etc.)

resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "lambda" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime

  s3_bucket = var.lambda_bucket # lambda code is stored 
  s3_key    = var.lambda_s3_key #

  lifecycle {
    ignore_changes = [s3_key]
  }
}