# provider "aws" {
#   region = "us-east-1"
# }

# resource "aws_vpc" "my-portfolio" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_support   = true
#   enable_dns_hostnames = true

#   tags = {
#     Name = "my-portfolio"
#   }
# }

# resource "aws_internet_gateway" "my-portfolio" {
#   vpc_id = aws_vpc.my-portfolio.id

#   tags = {
#     Name = "my-portfolio"
#   }
# }

# resource "aws_route_table" "my-portfolio" {
#   vpc_id = aws_vpc.my-portfolio.id

#   tags = {
#     Name = "my-portfolio"
#   }
# }

# resource "aws_route_table_association" "my-portfolio" {
#   subnet_id      = aws_subnet.my-portfolio-1.id
#   route_table_id = aws_route_table.my-portfolio.id
# }

# resource "aws_subnet" "my-portfolio-1" {
#   vpc_id      = aws_vpc.my-portfolio.id
#   cidr_block  = "10.0.1.0/24"

#   tags = {
#     Name = "my-portfolio-1"
#   }
# }

# resource "aws_subnet" "my-portfolio-2" {
#   vpc_id      = aws_vpc.my-portfolio.id
#   cidr_block  = "10.0.2.0/24"

#   tags = {
#     Name = "my-portfolio-2"
#   }
# }

# resource "aws_security_group" "my-portfolio" {
#   name   = "my-portfolio"
#   vpc_id = aws_vpc.my-portfolio.id

#   tags = {
#     Name = "my-portfolio"
#   }
# }

# # resource "aws_ecs_cluster" "my-portfolio" {
# #   name = "my-portfolio"
# # }

# # resource "aws_ecs_cluster" "default" { 
# #   name = "my-portfolio" 
# # }

# resource "aws_ecs_task_definition" "task" {
#   family                 = "my-portfolio"
#   container_definitions  = jsonencode([
#     {
#       name  = "my-portfolio",
#       image = "public.ecr.aws/z6s0c3o0/my-porfolio:latest",
#       essential = true,
#       memory = 512,
#       cpu    = 256,
#       portMappings = [{
#         containerPort = 3000,
#         hostPort      = 3000,
#       }],
#     },
#   ])
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   memory                   = "512"
#   cpu                      = "256"

#   tags = {
#     Name = "my-portfolio"
#   }
# }

# resource "aws_lb" "my-portfolio" {
#   name                = "my-portfolio"
#   internal            = false
#   load_balancer_type  = "application"
#   security_groups     = [aws_security_group.my-portfolio.id]
#   subnets             = [aws_subnet.my-portfolio-1.id, aws_subnet.my-portfolio-2.id]

#   tags = {
#     Name = "my-portfolio"
#   }
# }

# resource "aws_lb_target_group" "my-portfolio" {
#   name         = "my-portfolio"
#   port         = 3000
#   protocol     = "HTTP"
#   vpc_id       = aws_vpc.my-portfolio.id
#   target_type  = "ip"

#   health_check {
#     path                = "/"
#     protocol            = "HTTP"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#   }

#   tags = {
#     Name = "my-portfolio"
#   }
# }

# resource "aws_lb_listener" "my-portfolio-https" {
#   load_balancer_arn  = aws_lb.my-portfolio.arn
#   port               = "443"
#   protocol           = "HTTPS"

#   ssl_policy         = "ELBSecurityPolicy-2016-08"
#   certificate_arn    = data.aws_acm_certificate.my-portfolio.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.my-portfolio.arn
#   }

#   tags = {
#     Name = "my-portfolio-https"
#   }
# }

# resource "aws_lb_listener" "my-portfolio-http" {
#   load_balancer_arn  = aws_lb.my-portfolio.arn
#   port               = "80"
#   protocol           = "HTTP"

#   default_action {
#     type = "redirect"
#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }

#   tags = {
#     Name = "my-portfolio-http"
#   }
# }

# # resource "aws_ecs_service" "service" {
# #   name             = "my-portfolio"
# #   cluster          = aws_ecs_cluster.default.id
# #   task_definition  = aws_ecs_task_definition.task.arn
# #   desired_count    = 1
# #   launch_type      = "FARGATE"

# #   network_configuration {
# #     subnets          = [aws_subnet.my-portfolio-1.id, aws_subnet.my-portfolio-2.id]
# #     security_groups  = [aws_security_group.my-portfolio.id]
# #     assign_public_ip = true
# #   }

# #   load_balancer {
# #     target_group_arn = aws_lb_target_group.my-portfolio.arn
# #     container_name   = "my-portfolio"
# #     container_port   = 3000
# #   }

# #   tags = {
# #     Name = "my-portfolio"
# #   }
# # }

# data "aws_acm_certificate" "my-portfolio" {
#   domain      = "andrespulecio.com"
#   most_recent = true
#   tags = {
#     Name = "my-portfolio"
#   }
# }

# data "aws_route53_zone" "my-portfolio" {
#   name = "andrespulecio.com"
# }

# resource "aws_route53_record" "my-portfolio" {
#   zone_id = data.aws_route53_zone.my-portfolio.id
#   name    = "andrespulecio.com"
#   type    = "A"
#   alias {
#     name                   = aws_lb.my-portfolio.dns_name
#     zone_id                = aws_lb.my-portfolio.zone_id
#     evaluate_target_health = false
#   }
# }
