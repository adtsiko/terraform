output "s3_bucket_arn" {
    value = aws_s3_bucket.terraform_state.arn
    description = "S3 ARN"
  
}

output "dynamo_table" {
    value = aws_dynamodb_table.basic-dynamodb-table.name
  
}