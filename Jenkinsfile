pipeline {
    agent any

    environment {
        // Set the KUBECONFIG environment variable to point to Minikube's kubeconfig
        // This is crucial for kubectl and terraform-provider-kubernetes to find the cluster
        KUBECONFIG = "${env.HOME}/.kube/config"
    }

    stages {
        stage('Declarative: Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Start Minikube') {
            steps {
                script {
                    echo "Stopping any existing Minikube instances..."
                    sh 'minikube stop || true' // stop any running instance, ignore errors if none exist
                    echo "Deleting any old Minikube clusters..."
                    sh 'minikube delete || true' // delete any old cluster, ignore errors if none exist

                    echo "Starting Minikube..."
                    // Start Minikube with Docker driver and increased resources
                    sh 'minikube start --driver=docker --memory 1900 --cpus 2'

                    // Verify cluster is running and nodes are ready
                    echo "Verifying Kubernetes cluster info..."
                    sh 'kubectl cluster-info'
                    echo "Checking Kubernetes nodes status..."
                    sh 'kubectl get nodes'
                    echo "Checking Minikube status..."
                    sh 'minikube status'

                    // Wait for node to be ready
                    echo "Waiting for Minikube node to be ready..."
                    sh 'kubectl wait --for=condition=ready node/minikube --timeout=300s'

                    // Wait for CoreDNS deployment to be available
                    echo "Waiting for CoreDNS deployment to be available..."
                    sh 'kubectl wait --for=condition=Available deployment/coredns -n kube-system --timeout=300s'
                }
            }
        }

        stage('Terraform init') {
            steps {
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
            post {
                always {
                    archiveArtifacts artifacts: 'tfplan', fingerprint: true
                }
            }
        }

        stage('Approval for Apply') {
            steps {
                input message: 'Proceed with Terraform Apply?'
            }
        }

        stage('Terraform apply') {
            steps {
                sh 'terraform apply -input=false tfplan'
            }
        }

        // ADD THIS NEW STAGE HERE
        stage('Get Service URL') {
            steps {
                script {
                    echo "Getting Minikube IP and Service URL..."
                    def minikubeIp = sh(returnStdout: true, script: 'minikube ip').trim()
                    def serviceUrl = sh(returnStdout: true, script: 'minikube service nginx-service --url').trim()

                    echo "Minikube IP: ${minikubeIp}"
                    echo "Nginx Service URL: ${serviceUrl}"
                }
            }
        }
   }
}

post {
        success {
            echo "Pipeline finished successfully!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
