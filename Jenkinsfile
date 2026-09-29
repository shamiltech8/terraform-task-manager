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

        stage('Clean Workspace') {
            steps {
                sh '''
                    echo "===== CLEANING TERRAFORM WORKSPACE ====="

                    rm -rf .terraform
                    rm -f .terraform.lock.hcl
                    rm -f tfplan

                    echo "Workspace cleaned."
                '''
            }
        }

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
                        echo "===== TERRAFORM VERSION ====="

                        terraform version

                        echo ""
                        echo "===== TERRAFORM WORKSPACE ====="

                        terraform workspace show

                        echo ""
                        echo "===== TERRAFORM WORKSPACES ====="

                        terraform workspace list

                        echo ""
                        echo "===== TERRAFORM DIRECTORY ====="

                        ls -la .terraform

                        echo ""
                        echo "===== TERRAFORM BACKEND FILES ====="

                        find .terraform -maxdepth 3 -type f -print 2>/dev/null || true

                        echo ""
                        echo "===== TERRAFORM BACKEND CONFIGURATION ====="

                        grep -R "shamil-terraform-state-2026-148908330969" \
                            .terraform 2>/dev/null || true

                        echo ""
                        echo "===== TERRAFORM STATE PULL SIZE ====="

                        terraform state pull > /tmp/terraform-state-pull.json

                        wc -c /tmp/terraform-state-pull.json

                        echo ""
                        echo "===== TERRAFORM STATE PULL RESOURCES ====="

                        grep -E '"type":|"name":|"id":' \
                            /tmp/terraform-state-pull.json | head -80

                        echo ""
                        echo "===== DIRECT S3 STATE SIZE ====="

                        aws s3 cp \
                            s3://shamil-terraform-state-2026-148908330969/cloud-native-task-manager/terraform.tfstate \
                            /tmp/direct-s3-state.json

                        wc -c /tmp/direct-s3-state.json

                        echo ""
                        echo "===== DIRECT S3 STATE RESOURCES ====="

                        grep -E '"type":|"name":|"id":' \
                            /tmp/direct-s3-state.json | head -80
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
                        echo "===== S3 OBJECT ====="

                        aws s3api head-object \
                            --bucket shamil-terraform-state-2026-148908330969 \
                            --key cloud-native-task-manager/terraform.tfstate

                        echo ""
                        echo "===== TERRAFORM STATE LIST ====="

                        terraform state list
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
            archiveArtifacts(
                artifacts: 'tfplan',
                allowEmptyArchive: true
            )
        }
    }
}

