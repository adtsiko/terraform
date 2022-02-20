terraform{
    backend "s3"{
        key = "global/s3/terraform.tfstate"
    }
}
provider "aws" {
    region = "eu-west-2"
}

resource "aws_s3_bucket" "terraform_state" {

    bucket = "terraform-up-and-running-state-anesu-tsiko"
    #Prevent accidental deletion

    lifecycle{
      prevent_destroy = false
    }
    tags = {
        Name        = "terraform_bucket"
        Environment = "Dev"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "e3_encrypt" {
  bucket = aws_s3_bucket.terraform_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "terraform-up-and-running-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "s3_bucket_arn" {
    value = aws_s3_bucket.terraform_state.arn
    description = "S3 ARN"
  
}

output "dynamo_table" {
    value = aws_dynamodb_table.basic-dynamodb-table.name
  
}