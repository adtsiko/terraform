provider "aws" {
    region = "eu-west-2"
}

resource "aws_instance" "my_instance" {
    ami = "ami-0dd555eb7eb3b7c82"
    instance_type = "t2.micro"  
}