variable "aws_profile" {
  description = "Local AWS profile to use for AWS credentials"
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "AWS region to build in"
  type        = string
  default     = "us-east-1"
}

variable "aws_flow_logs_role_arn" {
  description = "ARN for the IAM role for publishing flow logs- https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-cwl.html"
  type        = string
}

variable "aws_flow_logs_log_arn" {
  description = "ARN for the CloudWatch Log group for publishing flow logs"
  type        = string
}
