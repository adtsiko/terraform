terraform{
    backend "s3"{
        key = "3-terraform_state/stage/services/web_cluster/terraform.tfstate"
    }
}
//AWS Provider
provider "aws" {
  region = "eu-west-2"
}

module "webserver_cluster"{
  source = "../../../module/services/webserver-cluster"

  cluster_name = "webservers-stage"
  db_remote_state_bucket = "terraform-up-and-running-state-anesu-tsiko"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size = 2
  max_size = 2
}

