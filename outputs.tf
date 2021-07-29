output "nexus3_ip" {
  value       = aws_eip.nexus3_eip.public_ip
  description = "The elastic IP address of the nexus3 instance."
}
