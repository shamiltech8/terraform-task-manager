# Terraform Task Manager Infrastructure

Infrastructure as Code for the **Cloud-Native Task Manager** project using Terraform, AWS, S3 remote state, and Jenkins CI/CD.

## Architecture

```text
GitHub
   │
   ▼
Jenkins
   │
   ▼
Terraform
   │
   ├── Security Group
   ├── EC2
   └── ECR
   │
   ▼
AWS

Terraform State
      │
      ▼
S3 Backend
```

## Technologies

* Terraform
* AWS
* Amazon EC2
* Amazon ECR
* Amazon VPC
* AWS Security Groups
* Amazon S3
* Jenkins
* GitHub

## Terraform Project Structure

```text
terraform-task-manager/
│
├── backend.tf
├── provider.tf
├── network.tf
├── security.tf
├── compute.tf
├── ecr.tf
├── variables.tf
├── outputs.tf
├── Jenkinsfile
├── README.md
├── .gitignore
└── .terraform.lock.hcl
```

## Infrastructure Managed

Terraform manages the following resources:

### EC2

The Task Manager EC2 instance is managed using the `aws_instance` resource.

Configuration includes:

* AMI
* instance type
* subnet
* security group
* key pair
* IAM instance profile
* public IP
* tags

### Security Group

Terraform manages the application's EC2 security group.

Current inbound access includes:

* SSH — port 22
* HTTP — port 80
* Flask application — port 5000 restricted to configured IP addresses

### ECR

Terraform manages the Docker image repository:

```text
cloud-native-task-manager
```

Terraform creates the repository infrastructure while Jenkins/Docker handles application image builds and pushes.

### VPC

The project reads the existing AWS default VPC using a Terraform data source rather than attempting to recreate the existing VPC.

## Remote State

Terraform uses an Amazon S3 backend.

The state is stored remotely and encrypted:

```hcl
terraform {
  backend "s3" {
    bucket       = "shamil-terraform-state-2026-148908330969"
    key          = "cloud-native-task-manager/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

Terraform state files are not committed to GitHub.

## Variables

Infrastructure-specific values are supplied through `terraform.tfvars` locally or through the CI/CD pipeline.

`terraform.tfvars` is excluded from Git using `.gitignore`.

## Basic Terraform Workflow

Initialize:

```bash
terraform init
```

Format:

```bash
terraform fmt
```

Validate:

```bash
terraform validate
```

Create a plan:

```bash
terraform plan
```

Create a saved plan:

```bash
terraform plan -out=tfplan
```

Apply the saved plan:

```bash
terraform apply tfplan
```

View outputs:

```bash
terraform output
```

View managed resources:

```bash
terraform state list
```

Inspect a resource:

```bash
terraform state show aws_instance.task_manager
```

## Jenkins CI/CD

The Terraform pipeline follows:

```text
GitHub
   │
   ▼
Jenkins
   │
   ├── Clean workspace
   ├── AWS authentication
   ├── Terraform init
   ├── Terraform validate
   ├── Create variables
   ├── Terraform plan
   ├── Manual approval
   └── Terraform apply
```

AWS credentials are stored in Jenkins Credentials rather than inside the Terraform source code or Jenkinsfile.

## Security

Current security practices include:

* AWS credentials are not hard-coded in Terraform.
* Terraform state is stored remotely.
* S3 backend encryption is enabled.
* State locking is enabled.
* Terraform state files are ignored by Git.
* `terraform.tfvars` is ignored by Git.
* Jenkins uses a stored AWS credential.
* Jenkins and EC2 use separate AWS identities.
* Flask port 5000 is restricted to configured IP addresses.
* ECR uses AES256 encryption.

Potential future improvements include:

* Restricting SSH access further.
* Adding HTTPS.
* Reviewing direct exposure of Flask port 5000.
* Enabling ECR image scanning.
* Removing hard-coded infrastructure values from the Jenkins pipeline.
* Further tightening IAM permissions.

## Verification

After deployment:

```bash
terraform plan
```

should report:

```text
No changes. Your infrastructure matches the configuration.
```

Check outputs:

```bash
terraform output
```

Check Terraform state:

```bash
terraform state list
```

Expected managed resources include:

```text
data.aws_vpc.default
aws_ecr_repository.task_manager
aws_instance.task_manager
aws_security_group.task_manager
```

## Relationship With the Main Application

This Terraform project is the infrastructure layer of the larger Cloud-Native Task Manager application.

The overall architecture is:

```text
GitHub
   │
   ▼
Jenkins
   │
   ├── Application Pipeline
   │      ├── Tests
   │      ├── Docker Build
   │      └── ECR Push
   │
   └── Infrastructure Pipeline
          ├── Terraform Plan
          ├── Approval
          └── Terraform Apply
                    │
                    ▼
                   AWS
```

Terraform manages infrastructure while Docker and Kubernetes manage application deployment.

## Project Goal

The goal of this project is to demonstrate practical Infrastructure as Code and DevOps practices by managing AWS infrastructure with Terraform and integrating Terraform into a Jenkins-based CI/CD workflow.
