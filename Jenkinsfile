pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                git(
                    url: 'git@github.com:shamiltech8/terraform-task-manager.git',
                    branch: 'main'
                )
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Approval') {
            steps {
                input message: 'Terraform plan reviewed. Apply the saved plan?'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply tfplan'
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'tfplan', allowEmptyArchive: true
        }
    }
}
