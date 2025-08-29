pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = "your-dockerhub-username"
        DOCKER_HUB_PASS = credentials('docker-hub-credentials') // Jenkins credentials
        IMAGE_NAME = "your-dockerhub-username/shopingkaro"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/nSanthoshperiasamy/ShopingKaro.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t $IMAGE_NAME:${BUILD_NUMBER} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    sh "echo $DOCKER_HUB_PASS | docker login -u $DOCKER_HUB_USER --password-stdin"
                    sh "docker push $IMAGE_NAME:${BUILD_NUMBER}"
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('infra') { // store terraform files in repo/infra
                    sh """
                    terraform init
                    terraform apply -auto-approve -var image_tag=${BUILD_NUMBER}
                    """
                }
            }
        }
    }
}
