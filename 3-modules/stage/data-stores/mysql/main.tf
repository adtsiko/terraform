terraform{
    backend "s3"{
        key = "stage/data-stores/mysql/terraform.tfstate"
    }
}
provider "aws" {
  region = "eu-west-2"
}

resource "aws_db_instance" "myswl_example" {
  allocated_storage    = 10
  engine               = "mysql"
  instance_class       = "db.t2.micro"
  db_name                 = "mydb"
  username             = "admin"
  password             = var.db_password
  skip_final_snapshot = true
}