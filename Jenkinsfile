pipeline {
    agent any

    environment {
        IMAGE_NAME   = "devops-app"
        IMAGE_TAG    = "${env.BUILD_NUMBER}"
        REGISTRY     = "docker.io/mionitra"
        FULL_IMAGE   = "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
        DOCKER_IMAGE = "${IMAGE_NAME}:${IMAGE_TAG}"
        DOCKERHUB    = credentials('dockerhub-credentials')
    }

    stages {
        stage('Code') {
            steps {
                echo 'Checking out code...'
                checkout scm
            }
        }

        stage('Scan sécurité') {
            steps {
                echo 'Running security scans (Bandit, Semgrep, Gitleaks)...'
                sh 'chmod +x scripts/scans/pre-build.sh'
                sh './scripts/scans/pre-build.sh'
            }
        }

        stage('Build image') {
    steps {
        echo 'Building Docker image...'
        sh "docker build -t ${DOCKER_IMAGE} -f docker/Dockerfile ."
    }
}

stage('Scan image') {
    steps {
        echo 'Scanning image...'
        sh 'chmod +x scripts/scans/build-scan.sh'
        sh './scripts/scans/build-scan.sh'
    }
}

stage('Push image') {
    steps {
        echo 'Pushing image to registry...'
        sh "docker tag ${DOCKER_IMAGE} ${FULL_IMAGE}"
        sh "docker push ${FULL_IMAGE}"
        // Capture the digest after push for signing
        script {
        env.IMAGE_DIGEST = "${FULL_IMAGE}"
    }
        echo "Pushed with digest: ${env.IMAGE_DIGEST}"
    }
}

stage('Signature') {
    steps {
        echo 'Signing image...'
        withCredentials([string(credentialsId: 'cosign-password-id', variable: 'COSIGN_PASSWORD')]) {
            sh 'chmod +x scripts/security/sign.sh'
            sh './scripts/security/sign.sh'
        }
    }
}

stage('Déploiement') {
    steps {
        script {
            echo 'Verifying signature before deployment...'
            sh 'chmod +x scripts/security/verify.sh'
            sh './scripts/security/verify.sh'
            echo 'Deploying application...'
        }
    }
}
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo 'Build successful!'
        }
        failure {
            echo 'Build failed. Please check reports in security-reports/ directory.'
        }
    }
}
