# resource "aws_alb" "entry-point" {
#   for_each           = toset(local.configuration.sdlc.environments)
#   name               = "entry-point" # Naming our load balancer
#   load_balancer_type = "application"

#   # Referencing the default subnets
#   subnets = aws_subnet.deployment.*.id
#   # Referencing the security group
#   security_groups = [
#     aws_security_group.entry-point[each.value].id,
#   ]
# }

# resource "aws_alb_listener" "entry-point" {
#   for_each = toset(local.configuration.sdlc.environments)

#   load_balancer_arn = aws_alb.entry-point[each.value].arn
#   protocol          = "HTTP"
#   port              = 80
#   default_action {
#     type = "redirect"
#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }

# resource "aws_alb_listener" "secure-entry-point" {
#   for_each = toset(local.configuration.sdlc.environments)

#   load_balancer_arn = aws_alb.entry-point[each.value].arn
#   protocol          = "HTTPS"
#   port              = 443
#   ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
#   certificate_arn   = aws_acm_certificate.entry-point[one(local.configuration.dns.zones)].arn
#   default_action {
#     type = "fixed-response"
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "OK"
#       status_code  = "200"
#     }
#   }
#   # depends_on = [ aws_acm_certificate.entry-point[each.value] ]
# }
