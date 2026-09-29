pipeline {

    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        TF_IN_AUTOMATION = 'true'
    }

    stages {

        stage('Clean Workspace') {
            steps {
                sh '''
                    echo "===== CLEANING TERRAFORM WORKSPACE ====="

                    rm -rf .terraform
                    rm -f .terraform.lock.hcl
                    rm -f terraform.tfstate
                    rm -f terraform.tfstate.backup
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

                        terraform init \
                            -reconfigure \
                            -migrate-state=false \
                            -input=false
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
                        find .terraform -maxdepth 3 -type f -print

                        echo ""
                        echo "===== TERRAFORM BACKEND CONFIGURATION ====="
                        grep -R "shamil-terraform-state-2026-148908330969" .terraform || true

                        echo ""
                        echo "===== TERRAFORM STATE PULL SIZE ====="
                        terraform state pull > /tmp/terraform-state-pull.json
                        wc -c /tmp/terraform-state-pull.json

                        echo ""
                        echo "===== TERRAFORM STATE PULL RESOURCES ====="
                        grep -E '"type":|"name":|"id":' /tmp/terraform-state-pull.json | head -80

                        echo ""
                        echo "===== DIRECT S3 STATE SIZE ====="
                        aws s3 cp \
                            s3://shamil-terraform-state-2026-148908330969/cloud-native-task-manager/terraform.tfstate \
                            /tmp/direct-s3-state.json

                        wc -c /tmp/direct-s3-state.json

                        echo ""
                        echo "===== DIRECT S3 STATE RESOURCES ====="
                        grep -E '"type":|"name":|"id":' /tmp/direct-s3-state.json | head -80
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

                        terraform plan \
                            -input=false \
                            -out=tfplan
                    '''
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'tfplan', allowEmptyArchive: true
        }
    }
}

