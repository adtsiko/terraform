output "address" {
    value = aws_db_instance.myswl_example.address
    description = "Connect to the database at this endpoint"
}

output "port" {
    value = aws_db_instance.myswl_example.port
    description = "database is listening on port"
}
