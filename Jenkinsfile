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

        stage('AWS Authentication Test') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-terraform-jenkins']
                ]) {
                    sh '''
                        echo "===== AWS IDENTITY ====="
                        aws sts get-caller-identity
                    '''
                }
            }
        }

        stage('Clean Terraform Workspace') {
            steps {
                sh '''
                    echo "===== CLEANING TERRAFORM WORKSPACE ====="

                    rm -rf .terraform
                    rm -f .terraform.lock.hcl
                    rm -f tfplan

                    echo "Terraform local metadata cleaned."
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-terraform-jenkins']
                ]) {
                    sh '''
                        echo "===== TERRAFORM INIT ====="

                        terraform init -reconfigure
                    '''
                }
            }
        }

        stage('Backend Diagnosis') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-terraform-jenkins']
                ]) {
                    sh '''
                        echo "===== TERRAFORM BACKEND METADATA ====="

                        cat .terraform/terraform.tfstate

                        echo ""
                        echo "===== TERRAFORM VERSION ====="

                        terraform version

                        echo ""
                        echo "===== TERRAFORM PROVIDERS ====="

                        terraform providers
                    '''
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

                        echo ""
                        echo "===== S3 STATE OBJECT ====="

                        aws s3api head-object \
                          --bucket shamil-terraform-state-2026-148908330969 \
                          --key cloud-native-task-manager/terraform.tfstate

                        echo ""
                        echo "===== TERRAFORM STATE LIST ====="

                        terraform state list

                        echo ""
                        echo "===== TERRAFORM STATE PULL ====="

                        terraform state pull | grep -E \
                          'i-0b44a5d32e4241f7b|sg-0062934f4aad9e2e5|cloud-native-task-manager' || true
                    '''
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                sh '''
                    echo "===== TERRAFORM VALIDATE ====="

                    terraform validate
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-terraform-jenkins']
                ]) {
                    sh '''
                        echo "===== TERRAFORM PLAN ====="

                        terraform plan -out=tfplan
                    '''
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
