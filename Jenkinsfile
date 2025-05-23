pipeline {
    agent any 

    environment {
        // Minikube typically sets KUBECONFIG automatically after start
        // Ensure this variable is present for kubectl and terraform
        KUBECONFIG = "${env.HOME}/.kube/config"
    }

    stages {
        stage('Start Minikube') {
            steps {
                script {
                    // Stop/delete existing minikube instance to ensure a clean start
                    sh 'minikube stop || true' // Stop if running
                    sh 'minikube delete || true' // Delete if exists
                    
                    // Start Minikube. Using --driver=docker is common.
                    // Adjust memory and CPU based on your Jenkins agent resources.
                    echo "Starting Minikube..."
                    sh 'minikube start --driver=docker --memory 1900 --cpus 2'
                    
                    // Verify Minikube is running and accessible
                    sh 'kubectl cluster-info'
                    sh 'kubectl get nodes'
                    sh 'minikube status'
                    
                    // Wait for the Kubernetes API server to be ready and accessible
                    // This is crucial to avoid "connection refused" errors
                    sh 'kubectl wait --for=condition=ready node/minikube --timeout=300s'
                    sh 'kubectl wait --for=condition=Available deployment/coredns -n kube-system --timeout=300s'
                }
            }
        }
        stage('Terraform init'){
            steps{
                sh 'terraform init -input=false'
            }
        }
        stage('Terraform validate'){
            steps{
                sh 'terraform validate'
            }
        }
        stage('Terraform plan'){
            steps{
                sh 'terraform plan -input=false -out=tfplan'
            }
            post{
                always{
                    archiveArtifacts artifacts: 'tfplan', fingerprint: true
                }
            }
        }
        stage('Approval for Apply'){
            steps{
                input message: 'Proceed with Terraform Apply?'
            }
        }
        stage('Terraform apply'){
            steps{
                sh 'terraform apply -input=false tfplan'
            }
        }
   }
}
