
//AWS Provider
provider "aws" {
  region = "eu-west-2"
}

// Instance having web server deployed using user_data 
resource "aws_launch_configuration" "launch_config" {
        image_id = "ami-0f9124f7452cdb2a6"
        instance_type = "t2.micro"
        security_groups = [aws_security_group.allow_tls.id]

        user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF  
       lifecycle {
            create_before_destroy = true
        }
}

resource "aws_lb" "aplication_load_balancer" {
    name = "terraform-asg"
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
  name = "terraformasglb"
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
        min_size = 2
        max_size = 10

        tag {
          key = "Name"
          value = "terraform-asg"
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
    name = "terraform_alb"
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


variable "server_port" {
    description = "Port for HTTP requests"
    type = number
    default = 8080
}
output "alb_dns_name" {
    value = aws_lb.aplication_load_balancer.dns_name
    description = "DNS of the load balancer"
  
}

data "aws_vpc" "default"{
    default = true
}

data "aws_subnet_ids" "default"{
    vpc_id = data.aws_vpc.default.id
} 