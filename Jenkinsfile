pipeline {
    agent { label 'build-node' }

    stages {
        stage('Checkstyle') {
            when {
                githubPullRequest()  // Triggered by PR events
            }
            steps {
                script {
                    sh './gradlew checkstyleMain'
                }
                archiveArtifacts artifacts: '**/build/reports/checkstyle/*.xml'
            }
        }

        stage('Test') {
            when {
                githubPullRequest()
            }
            steps {
                script {
                    sh './gradlew test'
                }
            }
        }

        stage('Build') {
            when {
                githubPullRequest()
            }
            steps {
                script {
                    sh './gradlew build -x test'
                }
            }
        }

        stage('Create Docker Image for Change Request') {
            when {
                githubPullRequest()
            }
            steps {
                script {
                    def gitCommit = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    withCredentials([usernamePassword(credentialsId: 'docker-login', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "docker login -u ${DOCKER_USER} -p ${DOCKER_PASSWORD}"
                        sh "docker build -t ${DOCKER_USER}/mr:${gitCommit} ."
                        sh "docker push ${DOCKER_USER}/mr:${gitCommit}"
                    }
                }
            }
        }

        stage('Create Docker Image for Main') {
            when {
                branch 'main'  // Only for the main branch
            }
            steps {
                script {
                    def gitCommit = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    withCredentials([usernamePassword(credentialsId: 'docker-login', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "docker login -u ${DOCKER_USER} -p ${DOCKER_PASSWORD}"
                        sh "docker build -t ${DOCKER_USER}/main:${gitCommit} ."
                        sh "docker push ${DOCKER_USER}/main:${gitCommit}"
                    }
                }
            }
        }
    }
}
