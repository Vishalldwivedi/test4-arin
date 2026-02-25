variable "lambda_function_name" { type = string }
variable "lambda_role_name"     { type = string }
variable "lambda_handler"       { type = string }
variable "lambda_runtime"       { type = string }
variable "lambda_bucket"        { type = string }  # this comes from s3 module output
variable "lambda_s3_key"       { type = string }