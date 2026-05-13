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
    env.IMAGE_DIGEST = sh(
        script: """
        docker buildx imagetools inspect ${FULL_IMAGE} \
        --format '{{json .Manifest.Digest}}' | tr -d '"'
        """,
        returnStdout: true
    ).trim()

    env.SIGN_TARGET = "${REGISTRY}/${IMAGE_NAME}@${IMAGE_DIGEST}"
}

echo "Using digest with the env sign_target: ${env.SIGN_TARGET}"
        echo "Pushed with digest with the image_digest: ${env.IMAGE_DIGEST}"
    }
}

        stage('Signature') {
    steps {
        echo 'Signing image...'
        withCredentials([
            string(credentialsId: 'cosign-private-password', variable: 'COSIGN_PASSWORD'),
            file(credentialsId: 'cosign-private-key', variable: 'COSIGN_KEY_FILE')
        ]) {
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

            echo 'Deploying application via Docker...'
            // Stop and remove existing container if it exists
            sh "docker ps -q --filter 'name=devops-app-container' | xargs -r docker stop"
            sh "docker ps -aq --filter 'name=devops-app-container' | xargs -r docker rm"

            // Run the new container mapping port 8000
            sh "docker run -d --name devops-app-container -p 8000:8000 ${DOCKER_IMAGE}"

            echo 'Application deployed and accessible at http://localhost:8000'
        }
    }
}
    }

    post {
        always {
            echo 'Pipeline finished.'
            archiveArtifacts artifacts: 'DevSecOps-tools/security-reports/**/*.json',
                            allowEmptyArchive: true,
                            fingerprint: true
        }
        success {
            echo 'Build successful!'
        }
        failure {
            echo 'Build failed. Please check reports in security-reports/ directory.'
        }
    }
}
