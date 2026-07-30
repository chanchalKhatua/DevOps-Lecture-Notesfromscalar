# Jenkins Pipeline Examples

> Production-ready Jenkins Pipeline examples for common DevOps workflows.

---

# 1. Basic Declarative Pipeline

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Building...'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing...'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying...'
            }
        }
    }
}
```

---

# 2. Git Checkout

```groovy
pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/user/repository.git'
            }
        }
    }
}
```

---

# 3. Maven Build

```groovy
pipeline {
    agent any
    tools {
        maven 'Maven3'
    }
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
    }
}
```

---

# 4. Docker Build & Push

```groovy
pipeline {
    agent any
    stages {
        stage('Build Image') {
            steps {
                sh 'docker build -t myapp:1.0 .'
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'docker-creds',
                        usernameVariable: 'USER',
                        passwordVariable: 'PASS'
                    )
                ]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                }
            }
        }

        stage('Push') {
            steps {
                sh 'docker push myapp:1.0'
            }
        }
    }
}
```

---

# 5. SonarQube Scan

```groovy
stage('SonarQube') {
    steps {
        withSonarQubeEnv('SonarQube') {
            sh 'mvn sonar:sonar'
        }
    }
}
```

---

# 6. Unit Test + JUnit Report

```groovy
stage('Test') {
    steps {
        sh 'mvn test'
    }
    post {
        always {
            junit 'target/surefire-reports/*.xml'
        }
    }
}
```

---

# 7. Parallel Testing

```groovy
stage('Tests') {
    parallel {
        stage('Unit Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Integration Test') {
            steps {
                sh './integration-test.sh'
            }
        }
    }
}
```

---

# 8. Retry & Timeout

```groovy
stage('Deploy') {
    steps {
        timeout(time: 15, unit: 'MINUTES') {
            retry(3) {
                sh './deploy.sh'
            }
        }
    }
}
```

---

# 9. Manual Approval

```groovy
stage('Approval') {
    steps {
        input message: 'Deploy to Production?'
    }
}
```

---

# 10. Kubernetes Deployment

```groovy
stage('Deploy') {
    steps {
        sh 'kubectl apply -f deployment.yaml'
        sh 'kubectl apply -f service.yaml'
    }
}
```

---

# 11. Helm Deployment

```groovy
stage('Helm Upgrade') {
    steps {
        sh 'helm upgrade --install app ./chart'
    }
}
```

---

# 12. Email Notification

```groovy
post {
    success {
        emailext(
            subject: 'Build Success',
            body: 'Deployment completed successfully.',
            to: 'team@example.com'
        )
    }

    failure {
        emailext(
            subject: 'Build Failed',
            body: 'Please check Jenkins logs.',
            to: 'team@example.com'
        )
    }
}
```

---

# 13. Slack Notification

```groovy
post {
    success {
        slackSend(
            channel: '#devops',
            message: "Build Successful"
        )
    }
}
```

---

# 14. Shared Library

```groovy
@Library('shared-lib') _

pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                buildApplication()
            }
        }
    }
}
```

---

# 15. Production Best Practices

- Use `timeout()` on long-running stages.
- Use `retry()` for transient failures.
- Never hardcode credentials.
- Use `withCredentials`.
- Archive artifacts.
- Clean the workspace after builds.
- Use immutable Docker image tags.
- Store reusable logic in Shared Libraries.
- Keep Jenkinsfiles small and modular.
