pipeline {
    agent any

    environment {
        TF_VAR_ami_id               = 'ami-01a00762f46d584a1'
        TF_VAR_instance_type        = 't3.micro'
        TF_VAR_subnet_id            = 'subnet-0c23ae939428c16d7'
        TF_VAR_security_group_id    = 'sg-0062934f4aad9e2e5'
        TF_VAR_key_name             = 'task-manger-key'
        TF_VAR_iam_instance_profile = 'CloudNativeTaskManagerEC2Role'
        TF_VAR_ecr_repository_name  = 'cloud-native-task-manager'
    }

    stages {

        stage('Checkout') {
            steps {
                git(
                    url: 'git@github.com:shamiltech8/terraform-task-manager.git',
                    branch: 'main'
                )
            }
        }

        stage('AWS Authentication Test') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-terraform-jenkins']
                ]) {
                    sh 'aws sts get-caller-identity'
                }
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-terraform-jenkins']
                ]) {
                    sh 'terraform init -reconfigure'
                }
            }
        }

        stage('Terraform State Diagnosis') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-terraform-jenkins']
                ]) {
                    sh '''
                        echo "===== AWS IDENTITY ====="
                        aws sts get-caller-identity

                        echo "===== S3 OBJECT ====="
                        aws s3api head-object \
                          --bucket shamil-terraform-state-2026-148908330969 \
                          --key cloud-native-task-manager/terraform.tfstate

                        echo "===== TERRAFORM STATE LIST ====="
                        terraform state list

                        echo "===== TERRAFORM STATE PULL ====="
                        terraform state pull | grep -E \
                          'i-0b44a5d32e4241f7b|sg-0062934f4aad9e2e5|cloud-native-task-manager' || true
                    '''
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-terraform-jenkins']
                ]) {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'tfplan',
                             allowEmptyArchive: true
        }
    }
}
