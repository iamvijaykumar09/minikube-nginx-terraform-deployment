pipeline {
    agent any
    environment {
        // Set KUBECONFIG env var to the path where Jenkins exposes the secret file
        KUBECONFIG = "${WORKSPACE}/.kube/config"
    }
    stages {
        stage('Terraform init') {
            steps {
                // Ensure the directory for the kubeconfig exists
                sh 'mkdir -p ~/.kube'
                // Use withCredentials to get the kubeconfig file and make it available
                withCredentials([file(credentialsId: 'minikube-kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                    sh 'cp $KUBECONFIG_FILE ~/.kube/config'
                }
                sh 'chmod +x ~/.kube/config'
                sh 'terraform init -input=false'
            }
        }
        stage('Terraform validate') {
            steps {
                sh 'terraform validate'
            }
        }
        stage('Terraform plan') {
            steps {
                sh 'terraform plan -input=false -out=tfplan'
            }
        }
        stage('Approval for Apply') {
            steps {
                input message: 'Proceed with Terraform Apply?', ok: 'Proceed or Abort'
            }
        }
        stage('Terraform apply') {
            steps {
                sh 'terraform apply -input=false tfplan'
            }
        }
    }
}
