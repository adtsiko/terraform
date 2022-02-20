terraform{
    backend "s3"{
        key = "2-terraform_state/dev/stage/services/web_cluster/terraform.tfstate"
    }
}
//AWS Provider
provider "aws" {
  region = "eu-west-2"
}

// Instance having web server deployed using user_data 
resource "aws_launch_configuration" "launch_config" {
        image_id = "ami-0f9124f7452cdb2a6"
        instance_type = var.instance_type
        security_groups = [aws_security_group.allow_tls.id]
        user_data = data.template_file.user_data.rendered
       lifecycle {
            create_before_destroy = true
        }
}

resource "aws_lb" "aplication_load_balancer" {
    name = "${var.cluster_name}-asg"
    load_balancer_type = "application"
    subnets = data.aws_subnet_ids.default.ids
    security_groups = [aws_security_group.alb.id]
  
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.aplication_load_balancer.arn
  port = 80
  protocol = "HTTP"

  # By default return a 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not FOUND"
      status_code = 404
    }
  }
}

#Target group

resource "aws_lb_target_group" "asg" {
  name = "${var.cluster_name}-alb_target_group"
  port =var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}
// Security Group 
resource "aws_autoscaling_group" "asg" {
        launch_configuration = aws_launch_configuration.launch_config.name
        vpc_zone_identifier = data.aws_subnet_ids.default.ids

        target_group_arns = [aws_lb_target_group.asg.arn]
        health_check_type = "ELB"
        min_size = var.min_size
        max_size = var.max_size

        tag {
          key = "Name"
          value = "${var.cluster_name}asg"
          propagate_at_launch =true
        }
}

resource "aws_lb_listener_rule" "asg_rule" {
    listener_arn = aws_lb_listener.http.arn
    priority = 100

    condition {
      path_pattern {
          values = ["*"]
      }
    }
    action {
      type = "forward"
      target_group_arn = aws_lb_target_group.asg.arn
    }
  
}

resource "aws_security_group" "alb" {
    name = "${var.cluster_name}_alb"
    #Allow HTTP inbound requests
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    #Allow outbound requests
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}
resource aws_security_group "allow_tls" {
     description = "Allow HTTP "
     name = "security_ec2"
     
 
     ingress {
     
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
     }

}

data "template_file" "user_data" {
  template = file("user-data.sh")

  vars = {
    server_port = var.server_port
    db_address = data.terraform_remote_state.db.outputs.address
    db_port = data.terraform_remote_state.db.outputs.port
  }
  
}
data "aws_vpc" "default"{
    default = true
}

data "aws_subnet_ids" "default"{
    vpc_id = data.aws_vpc.default.id
} 


data "terraform_remote_state" "db" {
    backend = "s3"

    config = {
      bucket = var.db_remote_state_bucket
      key = var.db_remote_state_key
      region = "eu-west-2"
    }

  
}