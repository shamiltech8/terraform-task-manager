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
                    echo "===== CLEANING WORKSPACE ====="

                    rm -rf .terraform
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
                     credentialsId: 'aws-terraform-jenkins'],
                    file(credentialsId: 'terraform-backend-hcl', variable: 'BACKEND_HCL')
                ]) {
                    sh '''
                        echo "===== TERRAFORM INIT ====="

                        terraform init \
                            -reconfigure \
                            -backend-config="$BACKEND_HCL" \
                            -migrate-state=false \
                            -input=false
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

        stage('Create Terraform Variables') {
            steps {
                withCredentials([
                    string(credentialsId: 'terraform-tfvars-text', variable: 'TFVARS_CONTENT')
                ]) {
                    sh '''
                        echo "===== PREPARING TERRAFORM VARIABLES ====="
                        printf '%s\n' "$TFVARS_CONTENT" > terraform.tfvars
                    '''
                }
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

        stage('Terraform Approval') {
            steps {
                input message: 'Review Terraform plan and approve deployment?',
                      ok: 'Approve and Apply'
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-terraform-jenkins']
                ]) {
                    sh '''
                        echo "===== TERRAFORM APPLY ====="

                        terraform apply \
                            -input=false \
                            -auto-approve \
                            tfplan
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
