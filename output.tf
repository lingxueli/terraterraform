output "lb_hostname" {
  value = aws_lb.front_end.dns_name
}
