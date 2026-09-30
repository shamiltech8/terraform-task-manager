variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "ami_id" {
  description = "AMI ID for the Task Manager EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID for the Task Manager EC2 instance"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the Task Manager EC2 instance"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile attached to the EC2 instance"
  type        = string
}

variable "ecr_repository_name" {
  description = "ECR repository name for the Task Manager application"
  type        = string
  default     = "cloud-native-task-manager"
}

variable "allowed_app_ips" {
  description = "IP addresses allowed to access the Task Manager application"
  type        = list(string)
}
