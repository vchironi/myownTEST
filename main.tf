terraform {
  cloud { 
    
    organization = "AWS_UN" 

    workspaces { 
      name = "tf-cloud-test" 
    } 
  } 
  
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.01"
    }
  }

 }





# Variable blocks directly within the main.tf. No arguments necessary.
#variable "aws_access_key" {}
#variable "aws_secret_key" {}
variable "region" {} 
# provider arguments call on the variables which then call on terraform.tfvars for the values.
provider "aws" {
  #access_key = var.aws_access_key
  #secret_key = var.aws_secret_key
  region     = var.region
}


# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# Attach the AWSLambdaBasicExecutionRole policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach the AmazonSESFullAccess policy to the IAM role
resource "aws_iam_role_policy_attachment" "ses_full_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

# Create a ZIP file from the Python script
data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "./"
  output_path = "./script.zip"
}

# Create an AWS Lambda function resource
resource "aws_lambda_function" "example" {
  function_name = "send-file-email"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.8"
  handler       = "script.lambda_handler"
  filename      = data.archive_file.zip.output_path

  source_code_hash = filebase64sha256(data.archive_file.zip.output_path)
}

# Create a CloudWatch event rule to trigger every 6 hours
resource "aws_cloudwatch_event_rule" "every_six_hours" {
  name                = "send-file-every-six-hours"
  schedule_expression = "rate(6 hours)"
}

# Create a CloudWatch event target to invoke the Lambda function
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_six_hours.name
  target_id = "lambda-target"
  arn       = aws_lambda_function.example.arn
}

# Grant permission to CloudWatch Events to invoke the Lambda function
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_six_hours.arn
}