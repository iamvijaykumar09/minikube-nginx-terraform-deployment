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
                    echo "Getting Minikube IP..."
                    def minikubeIp = sh(returnStdout: true, script: 'minikube ip').trim()
                    echo "Minikube IP: ${minikubeIp}"

                    echo "Getting Nginx service NodePort..."
                    // Get the NodePort for the nginx-service
                    def nodePort = sh(returnStdout: true, script: "kubectl get service nginx-service -o jsonpath='{.spec.ports[0].nodePort}'").trim()
                    echo "Nginx Service NodePort: ${nodePort}"

                    def finalUrl = "http://${minikubeIp}:${nodePort}"
                    echo "*****************************************************"
                    echo "Nginx Service URL (copy this): ${finalUrl}"
                    echo "*****************************************************"
                }
            }
        }
   }
}

post{
    success{
        echo 'Terraform pipeline completed successfully'
    }
    failure{
        echo 'Terraform pipeline failed'
    }
}
