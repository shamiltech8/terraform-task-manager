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
                sh '''
                    echo "===== CREATING TERRAFORM VARIABLES ====="

                    cat > terraform.tfvars <<'EOF'
ami_id               = "ami-01a00762f46d584a1"
instance_type        = "t3.micro"
subnet_id            = "subnet-0c23ae939428c16d7"
security_group_id    = "sg-0062934f4aad9e2e5"
key_name             = "task-manger-key"
iam_instance_profile = "CloudNativeTaskManagerEC2Role"
ecr_repository_name  = "cloud-native-task-manager"
EOF

                    echo "Terraform variables created."
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
