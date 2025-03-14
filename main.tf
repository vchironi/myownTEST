## PUT TERRAFORM CLOUD BLOCK HERE!  ##

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
resource "aws_iam_user" "test_user" {
  name = "user-${count.index}" 
  count = 3
  tags = {
    time_created = timestamp()    
    department = "OPSS"
  }
}

# Add .gitignore file in this directory with the terraform.tfvars

