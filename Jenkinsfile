pipeline{
    agent any
    
    stages{
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

post{
    always{
        cleanWs()
    }
    success{
        echo 'Terraform pipeline completed successfully'
    }
    failure{
        echo 'Terraform pipeline failed'
    }
}
