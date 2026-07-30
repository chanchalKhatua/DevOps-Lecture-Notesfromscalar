# Jenkins Cheat Sheet (Interview Revision)

> One-page-to-few-pages quick revision for Jenkins interviews.


# One-Line Definitions

| Term | One-Line Definition |
|------|----------------------|
| DevOps | Culture that combines Development and Operations to deliver software faster and reliably. |
| CI | Automatically build and test code after every commit. |
| Continuous Delivery | Keep software production-ready with a manual approval before release. |
| Continuous Deployment | Automatically deploy every successful change to production. |
| Jenkins | Open-source automation server used to build, test, and deploy applications. |
| Pipeline | Automated workflow that defines the CI/CD process. |
| Jenkinsfile | Pipeline configuration stored as code in the repository. |
| Controller | Central Jenkins server that schedules and manages jobs. |
| Agent | Worker machine that executes pipeline stages. |
| Workspace | Directory where Jenkins checks out code and runs builds. |
| Executor | Thread on an agent/controller that runs one build at a time. |
| Plugin | Extension that adds new functionality to Jenkins. |
| Freestyle Job | UI-based Jenkins job for simple automation. |
| Pipeline Job | Code-based Jenkins job defined in a Jenkinsfile. |
| Multibranch Pipeline | Automatically creates pipelines for repository branches. |
| Webhook | Event-based trigger that starts Jenkins immediately after a Git event. |
| SCM Polling | Jenkins periodically checks the repository for changes. |
| Shared Library | Reusable Groovy code shared across multiple pipelines. |
| Credential | Securely stored secret such as passwords, tokens, or SSH keys. |

# CI/CD
- **CI**: Frequently merge code, build, and test automatically.
- **Continuous Delivery**: Manual approval before production.
- **Continuous Deployment**: Automatic deployment after successful tests.

# Jenkins Core
- Automation Server
- Pipeline as Code (`Jenkinsfile`)
- 1800+ plugins
- Controller/Agent architecture

# Architecture
```
Developer
   │
Git Push
   │
GitHub
   │
Webhook
   │
Jenkins Controller
   │
Agent
   │
Build → Test → Deploy
```

# Common Job Types
- Freestyle
- Pipeline
- Multibranch Pipeline
- Matrix Job

# Declarative Pipeline Skeleton
```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Hello'
            }
        }
    }
}
```

# Important Directives
- agent
- stages
- stage
- steps
- post
- when
- environment
- parameters
- options
- tools
- input
- parallel
- matrix
- script

# Frequently Used Environment Variables
- BUILD_NUMBER
- BUILD_ID
- BUILD_URL
- JOB_NAME
- WORKSPACE
- NODE_NAME
- BRANCH_NAME

# Credentials
- Use Jenkins Credentials Store
- `withCredentials {}`
- Never hardcode secrets

# Build Triggers
- Build Now
- SCM Polling
- Webhook
- Remote API
- Upstream Job

# Agent Labels
```groovy
agent { label 'linux' }
```

# Parallel Example
```groovy
parallel {
    stage('Unit Test') {}
    stage('Integration Test') {}
}
```

# Retry & Timeout
```groovy
retry(3){
    sh 'make test'
}

timeout(time:10, unit:'MINUTES'){
    sh './deploy.sh'
}
```

# Shared Library
```
vars/
src/
resources/
```

# Monitoring
- Prometheus Metrics Plugin
- Grafana
- JVM Metrics
- Queue Length
- Executors
- Offline Agents

# Security
- Matrix Authorization
- Role Based Authorization
- Credentials Store
- Disable anonymous access
- Use API Tokens

# Best Practices
- Keep Jenkinsfiles small
- Use Shared Libraries
- Add timeout()
- Add retry()
- Use immutable image tags
- Archive artifacts
- Clean workspace
- Pin plugin versions

# Common Mistakes
- Hardcoded passwords
- Using latest tag
- No cleanup
- No notifications
- Huge Jenkinsfile
- Running builds on controller

# Troubleshooting
| Problem | Fix |
|---------|-----|
| Agent Offline | Check Java & SSH |
| Webhook Fails | Verify payload URL |
| Docker Login Failed | Check access token |
| Build Stuck | Check executors |
| Disk Full | Clean workspace |

# Important Commands
```bash
systemctl status jenkins
jenkins --version
kubectl get pods
docker ps
```

# Interview One-Liners
- Jenkins = Automation server.
- Pipeline = CI/CD workflow as code.
- Jenkinsfile = Pipeline definition.
- Controller schedules builds.
- Agents execute builds.
- Webhooks are event-driven.
- SCM Polling periodically checks repositories.
- Declarative is structured.
- Scripted is Groovy-based.
