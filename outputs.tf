output "gitlab_ips" {
  value       = aws_eip.gitlab_eip[*].public_ip
  description = "The elastic IP addresses of the gitlab instances."
}
output "gitlab_private_ips" {
  value       = aws_eip.gitlab_eip[*].private_ip
  description = "The private IP addresses of the gitlab instances."
}
