pipeline {
    agent none
    environment{
        DOCKERHUB_CREDENTIALS=credentials('a31bd8c3-a5c1-4992-a945-10728121152b')
    }

    stages {
        stage('git') {
            agent{
                label 'K8master'
            }
            steps {
                script{
                    git 'https://github.com/Venkat-Narayan-07/Website-PRT-ORG.git'
                }
            }
        }
        stage('docker') {
            agent{
                label 'K8master'
            }
            steps {
                script{
                    sh 'sudo docker build /home/ubuntu/jenkins/workspace/prtwebsite/ -t venkatnarayan16/website1'
                    sh 'sudo echo $DOCKERHUB_CREDENTIALS_PSW | sudo docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                    sh 'sudo docker push venkatnarayan16/website1'
                }
            }
        }
        stage('k8s') {
            agent{
                label 'K8master'
            }
            steps {
                script{
                    sh 'kubectl apply -f deployment.yml'
                }
            }
        }
    }
}
