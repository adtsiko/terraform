terraform{
    backend "s3"{
        key = "workspaces_isolation/terraform.tfstate"
        bucket = "terraform-up-and-running-state-anesu-tsiko"
        region = "eu-west-2"
        dynamodb_table = "terraform-up-and-running-locks"
        encrypt = true
    }
}
provider "aws" {
    region = "eu-west-2"
}

resource "aws_instance" "workspace_instance" {
    ami = "ami-0f9124f7452cdb2a6"
    instance_type = "t2.micro"
  
}