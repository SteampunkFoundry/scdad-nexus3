output "gitlab_ip0" {
  value       = aws_eip.gitlab_eip0.public_ip
  description = "The elastic IP address of the first gitlab instance."
}

output "gitlab_ip1" {
  value       = aws_eip.gitlab_eip1.public_ip
  description = "The elastic IP address of the second gitlab instance."
}
