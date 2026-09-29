output "task_manager_instance_id" {
  description = "Task Manager EC2 instance ID"
  value       = aws_instance.task_manager.id
}


output "task_manager_public_ip" {
  description = "Task Manager EC2 public IP"
  value       = aws_instance.task_manager.public_ip
}

output "task_manager_security_group_id" {
  description = "Task Manager security group ID"
  value       = aws_security_group.task_manager.id
}

output "task_manager_ecr_repository_url" {
  description = "Task Manager ECR repository URL"
  value       = aws_ecr_repository.task_manager.repository_url
}

output "task_manager_vpc_id" {
  description = "Default VPC ID used by the Task Manager infrastructure"
  value       = data.aws_vpc.default.id
}

output "task_manager_ecr_repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.task_manager.name
}
