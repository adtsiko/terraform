output "alb_dns_name" {
    value = aws_lb.aplication_load_balancer.dns_name
    description = "DNS of the load balancer"
  
}