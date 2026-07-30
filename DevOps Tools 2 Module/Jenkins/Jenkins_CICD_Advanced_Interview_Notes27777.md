# Jenkins & CI/CD — Advanced Interview-Ready Notes

> Consolidated, expanded notes from a 5-part Jenkins/CI-CD course (Introduction to CI/CD & Jenkins → Advanced Jenkins Concepts → Mastering Pipelines & Administration → Jenkins Miscellaneous → End-to-End Jenkins/Docker/Kubernetes Integration), reorganized and deepened for advanced-level interview preparation.

## Table of Contents

1. [CI/CD Foundations](#1-cicd-foundations)
2. [Introduction to Jenkins](#2-introduction-to-jenkins)
3. [Jenkins Architecture and Installation](#3-jenkins-architecture-and-installation)
4. [Jenkins Core Building Blocks](#4-jenkins-core-building-blocks)
5. [Jenkins Pipelines](#5-jenkins-pipelines)
6. [Pipeline Variables and Parameters](#6-pipeline-variables-and-parameters)
7. [Agent Management and Distributed Builds](#7-agent-management-and-distributed-builds)
8. [Build Triggers](#8-build-triggers)
9. [Advanced Pipeline Patterns](#9-advanced-pipeline-patterns)
10. [Error Handling and Resilience](#10-error-handling-and-resilience)
11. [Reports and Test Integration](#11-reports-and-test-integration)
12. [Notifications](#12-notifications)
13. [End-to-End Project: Jenkins, Docker, and Kubernetes](#13-end-to-end-project-jenkins-docker-and-kubernetes)
14. [Jenkins Administration](#14-jenkins-administration)
15. [Shared Libraries](#15-shared-libraries)
16. [Quick-Revision Cheat Sheet](#16-quick-revision-cheat-sheet)
17. [Interview Q&A Bank](#17-interview-qa-bank)

---

## 1. CI/CD Foundations

### 1.1 What is CI/CD?

CI/CD is a set of practices that automate how code travels from a developer's machine to production: **Continuous Integration**, **Continuous Delivery**, and **Continuous Deployment**.

### 1.2 Continuous Integration (CI)

**Definition:** Developers frequently (ideally several times a day) merge their code into a shared repository. Every merge is automatically verified by a build and a suite of tests.

**Purpose:**
- Early detection of integration issues
- Encourages collaboration among team members

**Process:**
1. Make changes to the code
2. Push to a repository (e.g., Git)
3. **Build** — turn source code into an executable: compiling, dependency management, packaging (typically via **Maven** or **Gradle**)
4. **Test** — unit tests, performance tests, integration tests

**Benefits:**
- Faster feedback on code changes
- Fewer integration headaches later in the cycle
- Higher code quality via automated testing

> Analogy: think of several authors (W1–W5) each writing sections that continuously feed into a single manuscript draft before it goes to a publisher — that's CI. Multiple developers (D1–D4) constantly pushing into one shared GitHub repo is the software equivalent.

### 1.3 Continuous Delivery vs. Continuous Deployment

Both extend CI by automating everything **up to** production — the difference is the final step.

| Feature | Continuous Delivery | Continuous Deployment |
|---|---|---|
| **Definition** | Code is always in a deployable state and can be released anytime with a manual approval step | Every change that passes automated tests is deployed to production, fully automated |
| **Deployment Trigger** | Manual (e.g., a button click / approval) | Automatic (no manual intervention) |
| **Testing Required** | Rigorous automated testing to ensure stability | Even stricter automated testing — no human safety net before prod |
| **Risk Factor** | Lower — human verification before release | Higher — a faulty change can reach production if tests fail to catch it |
| **Use Case** | Regulated industries (finance, healthcare) where approval is required | Consumer applications (e.g., Facebook, Netflix) needing fast, frequent releases |

**Continuous Delivery flow (book-publishing analogy):**
```
Writers (W1–W3) → Draft (Book) → Pre-publishing review (waiting for final approval) → Approved → Print
Devs (D1–D4) → GitHub → Staging env → tests → Approval → Production
```

**Continuous Deployment flow:**
```
Writers (W1–W3) → Draft (Book) → Ready to be published and printed (runs automatically)
Devs (D1–D4) → GitHub → Staging env → tests → Production (no manual approval)
```

> **Interview Insight:** The cleanest way to state the difference: "Delivery has a human in the loop before prod; Deployment doesn't." Everything else (testing rigor, risk profile, industry fit) follows from that one distinction.

### 1.4 The Four CD Phases

1. **Release** — versioning the build; artifacts are stored in a registry (Docker Hub, Nexus, Artifactory, etc.)
2. **Deploy** — strategies include **Blue-Green**, **Canary**, and **Rolling updates** (full definitions in the [Interview Q&A Bank](#17-interview-qa-bank), Q21)
3. **Monitor** — track application/infrastructure health post-release
4. **Operate** — includes **autoscaling** and **Disaster Recovery (DR)** / rollback mechanisms

### 1.5 The CI/CD Infinity Loop

```
PLAN → CODE → BUILD → TEST            (Continuous Integration)
   ↕
RELEASE → DEPLOY → OPERATE → MONITOR   (Continuous Delivery / Deployment)
```
This loops continuously — monitoring feeds back into planning the next change.

### 1.6 Where Does Jenkins Fit?

Jenkins is the **automation engine** at the center of this loop. It's the tool that actually *executes* the Build, Test, Release, and Deploy stages — orchestrating compilers, test runners, Docker, cloud CLIs, and deployment tools according to rules you define.

---

## 2. Introduction to Jenkins

### 2.1 What is Jenkins?

Jenkins is an **open-source automation server** that automates software development processes: building, testing, and deploying.

> "It allows developers to integrate their code frequently and ensures that software is always in a deployable state."

**What Jenkins does, at its core:**
- **Building** the code
- **Testing** the code
- **Deploying** the application

**Key features:**
- Automates repetitive tasks in software delivery
- Integrates with virtually everything: Docker, AWS, GitHub, Kubernetes, Slack, and more

### 2.2 Why Jenkins Is Still Relevant (common interview question)

1. **Massive Adoption & Ecosystem** — Jenkins has been around for roughly two decades (launched around 2004 as **Hudson**, renamed **Jenkins** in 2011 after a dispute with Oracle). Deeply embedded in many organizations' CI/CD workflows. Over **1,800 plugins** let it integrate with almost any tool or cloud provider.
2. **Flexibility & Customization** — supports any type of pipeline, from legacy monoliths to modern microservices; works on-premise, hybrid, or in the cloud.
3. **Enterprise Support & Legacy Systems** — large enterprises, especially in regulated industries, rely on Jenkins because stability and security matter more than bleeding-edge tooling.
4. **Open-Source & Free** — 100% open-source, no licensing costs, backed by a large community delivering continuous improvements, security patches, and plugins.
5. **Easy to Set Up & Use** — installs quickly on anything from a laptop to a cloud server; a simple Java-based install gets a team started with minimal effort.

> **Interview Insight:** If asked "why not GitHub Actions / GitLab CI / CircleCI instead?" — the honest framing is that Jenkins trades "batteries-included simplicity" for **self-hosted control** and an **unmatched plugin ecosystem** that works identically regardless of which cloud, SCM, or container platform you use. Newer hosted CI tools are often faster to start with but more tightly coupled to one ecosystem.

---

## 3. Jenkins Architecture and Installation

### 3.1 Core Architecture (Controller/Agent model)

> **Terminology note:** Jenkins historically used **Master/Slave**. Current official documentation uses **Controller** (was Master) and **Agent** (was Slave). Both terms are still common in the wild and in interviews — know both.

**Controller (Master)** — the central Jenkins server. Responsible for:
- Managing jobs
- Serving the **UI** / web interface
- **Scheduling builds**
- **Storing build logs** (build history)
- **Managing plugins**
- Holding configuration and credentials

**Agent (Slave)** — a remote executor that offloads job execution from the controller to improve scalability. **Must have Java installed** to communicate with the controller.

**Plugins** — extend Jenkins' capabilities (Git, Docker, Kubernetes, Pipeline, etc.)

```
web-interface  →  Controller (Master)  →  Agent(s) / Slave(s)
                   [Jenkins Server]
                   - Jobs
                   - Users
                   - Plugins
                   - Nodes
                   - Credentials
                   - Configuration
```

**Jenkins Core Components:**

| Component | Role |
|---|---|
| Jenkins Server (Controller) | Centralized orchestration, configuration, jobs |
| Jobs | Tasks/projects Jenkins executes |
| Users | Access & permission management |
| Plugins | Feature extensions |
| Agents / Nodes | Remote, distributed execution |

### 3.2 Installation Requirements

- Minimum **1 GB RAM** (more recommended for real projects)
- Minimum **4 GB disk space**
- **Java 11 or 17** (17 recommended)

### 3.3 Installing Jenkins on Ubuntu (step by step)

```bash
# 1. Update the system and install Java
sudo apt update && sudo apt upgrade -y
sudo apt install -y fontconfig openjdk-17-jre

# 2. Add the Jenkins repository key and source
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# 3. Install Jenkins
sudo apt update
sudo apt install -y jenkins

# 4. Start Jenkins and enable it on boot
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

### 3.4 First-Time Setup

1. **Access the GUI:** `http://<ip>:8080`
2. **Unlock Jenkins** using the initial admin password:
   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
3. Install the suggested plugins (or select manually)
4. **Create the first admin user** → click "Start using Jenkins"

---

## 4. Jenkins Core Building Blocks

### 4.1 Jobs

Jobs define **how** the CI/CD process runs. A job can:
- Build code
- Run tests
- Deploy applications
- Automate any repetitive task

**Types of Jenkins Jobs:**

| Type | Description |
|---|---|
| **Freestyle Project** | Simple, UI-configured project; good for basic automation |
| **Pipeline Project** | Entire build process defined as code in a `Jenkinsfile`; version-controlled, flexible |
| **Multi-Configuration (Matrix) Job** | Runs the same job across multiple environment combinations (OS, browser, etc.) |

Example freestyle "job content" (a shell build step):
```bash
echo "Hello DevOps Learners!"
pwd
cp $0 /var/lib/jenkins/workspace/saved-script.sh
export NO_CLEANUP=true
```

### 4.2 Users and Role-Based Access Control (RBAC)

Roles define **what a user can and can't do**:

| Role | Capabilities |
|---|---|
| **Administrator** | Full control — install plugins, create jobs, manage users |
| **Job Creator** | Create/modify jobs; cannot manage Jenkins settings |
| **Job Executor** | Can run jobs; cannot modify them |
| **Read-Only User** | Can view job status, logs, and configuration; **cannot** trigger builds or make changes |

**Setup flow:** install the **Role-based Authorization Strategy** plugin → create the role → assign the role to users/groups.

### 4.3 Plugins

Plugins are how Jenkins integrates with almost everything — Git, Docker, Kubernetes, Slack, email, cloud providers, and more. There are over **1,800 plugins** in the ecosystem, covering nearly every tool a DevOps team might use.

### 4.4 Nodes / Agents

Covered in depth in [Section 7](#7-agent-management-and-distributed-builds).

### 4.5 Credentials

Jenkins securely stores secrets — SSH keys, API tokens, usernames/passwords, cloud credentials — so they're never hardcoded into pipeline scripts.

**Credential Stores** — *where* credentials physically live:

| Store Type | Description |
|---|---|
| **System** | Globally available to Jenkins and all its components |
| **User** (if enabled) | Each user has a personal store |
| **Folder-specific** | Each Jenkins folder can have its own credential store |
| **Job-specific** | Some plugins allow credentials attached at the job level |

**Domains** — used to *organize and group* credentials (e.g., a "dev-domain" vs. a "prod-domain"), scoping which credentials are visible to which jobs/environments.

| Aspect | Domain | Store |
|---|---|---|
| **Purpose** | Categorizes and scopes credentials | Stores and holds credentials in the Jenkins environment |
| **Scope** | Defines which credentials are available to specific jobs/environments | A centralized repository where all credentials are stored |
| **Use Case** | Segregates credentials by project, team, or environment | Manages the creation, modification, and deletion of credentials |
| **Example** | "dev-domain", "prod-domain" | Global store or external credential stores |

**Using credentials inside a pipeline:**
```groovy
withCredentials([usernamePassword(
    credentialsId: 'vedant',
    usernameVariable: 'USERNAME',
    passwordVariable: 'PASSWORD'
)]) {
    echo "Username: ${USERNAME}"
    echo "Password: ${PASSWORD}"
}
```

> **Interview Insight:** Jenkins automatically masks known credential values in console output, but treat `echo`-ing a secret as a demo pattern only — never rely on masking as your real security control. Prefer scoping the credential to only the steps that need it (as shown above), and avoid printing secrets at all in production pipelines.

---

## 5. Jenkins Pipelines

### 5.1 What Is a Pipeline?

A **Jenkins Pipeline** is an automated sequence of steps that defines how code moves from development to production. It automates **build, test, and deployment** in a structured, repeatable way.

> **Analogy:** a car factory — parts get assembled, then painted, then quality-checked, then shipped. Each station is a **stage**; the whole line is the **pipeline**.

Typical flow:
```
Checkout → Build → Test → Deploy
```
or simply:
```
Build → Test → Deploy
```

**Common pipeline stages:**
- **Checkout** — pulls source from version control (e.g., Git)
- **Build** — compiles source into deployable artifacts (binaries)
- **Unit Test** — validates individual software modules
- **Regression Test** — ensures new changes don't break existing functionality
- **Preprod Deployment** — deploys to a pre-production environment for final validation

### 5.2 Jenkinsfile & Pipeline as Code

A **Jenkinsfile** is the text file — checked into source control alongside your app code — that defines the pipeline. This is what "**Pipeline as Code**" means: the build process is versioned, reviewable, and reproducible, exactly like application code.

### 5.3 Declarative vs. Scripted Pipelines

| Feature | Declarative | Scripted |
|---|---|---|
| **Structure** | Enforces a strict structure (single `pipeline {}` block) | More flexible, no enforced structure |
| **Simplicity** | Easier to read and write | More complex, requires Groovy scripting knowledge |
| **Maintainability** | Easier to maintain | Harder to manage for complex workflows |
| **When to use** | Simple-to-medium CI/CD pipelines | Advanced scenarios needing fine-grained control |
| **Error Handling** | `post` blocks (`failure`, `always`, `success`) | `try / catch / finally` |
| **Conditional Execution** | `when` conditions | `if` statements |
| **Readability** | More readable and maintainable | Less readable for beginners |
| **Validation** | **Fails fast** — full syntax validated before any stage runs | No upfront validation — errors surface at runtime |
| **Introduced** | Jenkins 2.x, as a simpler, modern approach | The original / legacy pipeline style |
| **Underlying model** | Structured, predefined syntax/keywords | Written in Groovy with a programmatic approach; uses `node {}` blocks |

**Declarative Pipeline example:**
```groovy
pipeline {
    agent any
    options {
        preserveStashes() // Enables restarting from a failed stage
    }
    stages {
        stage('Clone Repository') {
            steps {
                echo 'Cloning repository...'
                git branch: 'jenkins', url: 'https://github.com/<user>/testing_repo.git'
            }
        }
        stage('Build') {
            steps {
                echo 'Building application...'
            }
        }
        stage('Test') {
            steps {
                echo 'Running tests...'
            }
        }
    }
}
```

**Scripted Pipeline example:**
```groovy
node {
    stage('Clone Repository') {
        echo 'Cloning repository...'
        git branch: 'jenkins', url: 'https://github.com/<user>/testing_repo.git'
    }
    stage('Build') {
        echo 'Building application...'
    }
    stage('Test') {
        echo 'Running tests...'
    }
}
```

> **Interview Insight — the one that actually matters:** Declarative pipelines validate the *entire* syntax before running a single stage. Write `stepa` instead of `steps` by accident, and a Declarative pipeline refuses to start at all. A Scripted pipeline is plain Groovy executed top-down with no such upfront check — the same typo might behave completely differently since there's no structural validation pass. This is the practical difference behind "Declarative fails fast."

**General pros and cons:**
- **Scripted** — highly customizable for unique/complex workflows, can accommodate non-standard CI/CD requirements; but has a steep learning curve, higher potential for errors from manual coding, and requires careful debugging/maintenance.
- **Declarative** — simplifies pipeline creation with a predefined structure, automatically validates syntax before execution, encourages standardization across teams; but is less flexible and may not suit highly customized/complex workflows.

### 5.4 Pipeline Building Blocks Reference

| Block / Directive | Purpose |
|---|---|
| `pipeline {}` | Declarative wrapper (Declarative pipelines only) |
| `node {}` | Defines where to run (Scripted pipelines) |
| `agent` | Defines the execution environment — `agent any`, `agent { label 'ec2-agent' }`, `agent none` |
| `stages {}` → `stage('Name') {}` → `steps {}` | The structural hierarchy of a Declarative pipeline |
| `script {}` | Drop into Scripted-style Groovy *inside* a Declarative pipeline — an escape hatch for complex logic |
| `post {}` | Post-build actions: `always`, `success`, `failure`, `unstable`, `changed` |
| `environment {}` | Define environment variables |
| `parameters {}` | Define build parameters |
| `options {}` | Pipeline-level options (timeouts, retries, preserving stashes, etc.) |

### 5.5 Pipeline Architecture: Master–Slave / Controller–Agent

Jenkins uses a distributed architecture for scalability and performance:
- **Master/Controller** — the central server that orchestrates pipeline execution, delegating tasks to agent nodes based on pipeline requirements.
- **Slave/Agent** — remote nodes responsible for actually executing tasks (build, test, deploy). Must have **Java** installed to communicate with the master/controller.

**Labels:**
- **Agent Labels** — tag agents based on role/capability (e.g., "linux-agent", "windows-agent")
- **Node Labels** — identify where a particular pipeline stage should execute

**Pipeline topology patterns:**

*Single Server Pipeline* — all tasks (checkout, build, test, deploy) run on one server.
- Ideal for small-scale projects with limited resource needs
- Simple to configure and manage
- Limited scalability; can become a bottleneck

*Multi-Node Pipeline* — tasks distributed across multiple nodes.
- Example: Node 1 = checkout + build; Node 2 = testing (unit + regression); Node 3 = deployment
- Suitable for large-scale, complex projects
- Better resource utilization and reduced execution time
- Requires careful node configuration/management

---

## 6. Pipeline Variables and Parameters

### 6.1 Built-in Environment Variables

Jenkins automatically exposes environment variables for every build:

| Variable | Meaning |
|---|---|
| `BUILD_NUMBER` | Current build number (integer, increments each run) |
| `BUILD_ID` | Unique identifier for the current build (timestamp-based) |
| `BUILD_URL` | URL to view details of the current build |
| `JOB_NAME` | Name of the job |

Full reference: `http://<jenkins-ip>:8080/env-vars.html`

### 6.2 Custom Environment Variables

```groovy
pipeline {
    agent any
    environment {
        MY_VAR = 'Hello, World!'
        ENVIRONMENT = 'production'
    }
    stages {
        stage('Build') {
            steps {
                echo "Environment: $ENVIRONMENT"
                echo "Custom message: $MY_VAR"
            }
        }
    }
}
```

### 6.3 Global Environment Variables

Set once, available to every pipeline on the instance:
`Manage Jenkins → Configure System → Global Properties → check "Environment Variables" → add key-value pairs`

### 6.4 Build Parameters (Parameterized Jobs)

Lets a human (or an upstream trigger) supply input before a build runs.

```groovy
pipeline {
    agent any
    parameters {
        string(name: 'ENVIRONMENT', defaultValue: 'dev', description: 'Deployment environment')
        booleanParam(name: 'DEPLOY', defaultValue: true, description: 'Should we deploy?')
    }
    stages {
        stage('Build') {
            steps {
                echo "Building for environment: ${params.ENVIRONMENT}"
                echo "Should deploy? ${params.DEPLOY}"
            }
        }
    }
}
```

**Common parameter types:**
- `string` — free text input
- `booleanParam` — checkbox (true/false)
- `choice` — dropdown, choose exactly **one** option (e.g., `dev`, `staging`, `prod`)
- **Extended Choice / Checkbox Parameter plugin** — multi-select checkboxes (choose **one or more**)

**Demo: Checkbox Parameterized Pipeline**
1. Install the **Checkbox Parameter** (Extended Choice Parameter) plugin
2. Define the option set, e.g. `['Build', 'Test', 'Deploy']`
3. At build time, the user selects any combination (e.g., only "Build" + "Deploy", skipping "Test")

---

## 7. Agent Management and Distributed Builds

### 7.1 Why Distribute Builds Across Agents?

1. **Distributed workload** — spread jobs across multiple machines instead of bottlenecking one server
2. **Specialized environments** — some jobs need a specific OS/toolchain (Windows agent vs. Linux agent, GPU agent, etc.)
3. **Isolation** — keep untrusted or heavy jobs off the controller itself

**Labels** connect pipelines to the right agents — tag agents with labels (e.g., `linux`, `docker`, `ec2-agent`), and pipelines request an agent by label:

```groovy
pipeline {
    agent { label 'ec2-agent' }   // ensures this job runs on a specifically labeled agent
    stages {
        stage('Build') {
            steps {
                echo 'Building project...'
                sh 'sleep 10'
            }
        }
        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'echo "Tests Passed!"'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                sh 'echo "Deployment Complete"'
            }
        }
    }
}
```

### 7.2 Setting Up an EC2 Instance as a Jenkins Agent

**Step-by-step:**
1. **Provision the EC2 instance**
2. **Install Java** on it (agents need Java to talk to the controller)
3. **Configure Security Groups** (open the right ports for controller ↔ agent communication)
4. **Add SSH key credentials** in Jenkins
5. **Connect the agent to Jenkins** (Manage Jenkins → Nodes → New Node)
6. **Use labels** to target jobs at this agent
7. **Run a pipeline** against it

**SSH Host Key Verification Strategies** (chosen when connecting Jenkins to a new agent via SSH):

| Strategy | Description | Use Case |
|---|---|---|
| **Manually Trusted Key** (recommended) | Jenkins prompts for manual approval when an agent first connects; future connections are trusted | Secure environments where you want to manually verify SSH host keys before accepting them |
| **Known Hosts File** | Uses the standard `~/.ssh/known_hosts` file for verification; connection fails if the key is missing or changed | Pre-configured environments where SSH keys are already managed (e.g., via Ansible, Puppet, or Chef) |
| **Accept First Connection** | Accepts the first connection without verification; future key changes will cause failures | Non-production environments where initial security isn't a concern |
| **No Host Key Verification** | Disables host key verification completely, allowing connections without authentication | Testing environments only — **not recommended for production** |

### 7.3 Advantages of Distributed Agents (recap)

1. Distributed workload
2. Specialized environments
3. Isolation

---

## 8. Build Triggers

### 8.1 Why Automate Triggers?

1. **Save time**
2. **Reduce human error**
3. **Ensures CI/CD** actually happens continuously — builds fire the moment code changes, not "whenever someone remembers to click Build"

### 8.2 Types of Build Triggers

1. **Manual** — press "Build Now"
2. **Scheduled** — build runs at fixed times (cron-like syntax)
3. **Triggered remotely** — an external system calls Jenkins via HTTP + a token/API
4. **Dependency-based** — "Build after other projects are built" (chained execution)
5. **SCM Polling**
6. **Webhook Trigger**

> Analogy for dependency-based triggers: making coffee needs "add water → add milk → add coffee" — each step depends on the previous one finishing. Jenkins job chains work the same way.

### 8.3 Build After Other Projects Are Built (Chained Jobs)

**Use case:** Job1 completes → Job2 starts → Job2 completes → Job3 starts. This is essentially a hand-rolled pipeline built from Freestyle jobs — a simple form of chained execution/orchestration, without writing an actual `Jenkinsfile`.

### 8.4 SCM Polling

Jenkins checks the repository at fixed intervals for new commits. If a new commit is found, a build triggers automatically.

**Downside:** it periodically checks even when nothing has changed — wasted resource consumption, and an inefficient approach at scale.

**Setup steps:**
1. Create a new Job
2. Configure the Git repository in Jenkins
3. Enable **Poll SCM**
4. Add a build step
5. **Test:** push a new file to GitHub → Jenkins detects it on the next poll → build triggers automatically

```
Git <---(periodically polled)--- Jenkins
      new commit? -> yes -> trigger build automatically
```

### 8.5 Webhooks

A **webhook** lets one system notify another about an event **in real time**. Instead of Jenkins repeatedly asking "did anything change?", GitHub tells Jenkins the instant something changes.

**Why webhooks over polling:**
- **Instant Builds** — Jenkins is notified immediately, unlike polling which waits for the next scheduled check
- **Efficient** — reduces unnecessary server load caused by frequent polling
- **Better CI/CD** — a faster feedback loop for developers

**Implementation steps:**
1. **Create a webhook in Git** — GitHub repo → Settings → Webhooks → Add Webhook → paste the Jenkins webhook URL → select "trigger on push events" → save and test
2. **Create/configure the pipeline in Jenkins** to listen for webhook events (repo, trigger, and pipeline script/code)
3. **Test** — commit and push:
   ```bash
   git commit -am "Updated deployment file"
   git push origin main
   # -> the Jenkins pipeline should start automatically
   ```

**Required plugins:** GitHub plugin, GitHub Integration plugin

**Also webhook-driven:**
- **GitHub Branches** — multibranch scanning triggers builds for the specific branch that changed
- **GitHub Pull Requests** — Jenkins can trigger builds on PR creation and updates

> **Note:** GitHub's API has **rate limits** — heavy polling or repeated scanning across many branches can hit these limits. This is another reason webhooks (event-driven) scale better than polling at organizational scale.

### 8.6 Triggering Builds Remotely (API)

Trigger a build with a plain HTTP request, authenticated by a **build token** plus a personal **API token**:

```bash
curl -X POST "http://<JENKINS_SERVER_IP>:8080/job/GitHub-Pipeline-Demo/build?token=my-secret-token" \
  --user "your-username:your-api-token"
```

**Setup steps:**
1. Create the pipeline job and set a **Trigger token name** (Job config → Build Triggers → "Trigger builds remotely")
2. Create an **API token** (Jenkins → your profile → Security → API Token)
3. Create the `Jenkinsfile`
4. Trigger the build with `curl` as shown above

---

## 9. Advanced Pipeline Patterns

### 9.1 Parallel Pipelines

A **Parallel Pipeline** runs independent stages **simultaneously** rather than sequentially — a major time-saver whenever stages don't depend on each other.

**Worked example 1:**

| Stage | Duration | Dependency |
|---|---|---|
| Stage 1 | 10 min | Stages 1 & 2 must run sequentially (2 depends on 1) |
| Stage 2 | 5 min | |
| Stage 3 | 15 min | No dependency — can run in parallel with Stage 4 |
| Stage 4 | 15 min | No dependency |

Most efficient plan: run Stage 1 → Stage 2 sequentially (10 + 5 = 15 min), then run Stage 3 and Stage 4 **in parallel** (max(15, 15) = 15 min).
**Total = 15 + 15 = 30 minutes**, instead of 45 minutes if everything ran sequentially (10+5+15+15).

**Worked example 2 (from the course):** JUnit testing (5 hours) and Regression testing (7 hours) run sequentially would take **12 hours** combined. Since they're independent, running them **in parallel** drops the total time to **7 hours** (the duration of the longer stage).

**Why use parallel pipelines:**
1. Speeds up execution
2. More efficient resource utilization
3. Better pipeline structure and scalability

**Code:**
```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo "Building the application..."
                sh 'sleep 15'
            }
        }
        stage('Parallel Execution') {
            parallel {
                stage('Test') {
                    steps {
                        echo "Running tests..."
                        sh 'sleep 15'
                    }
                }
                stage('Deploy') {
                    steps {
                        echo "Deploying application..."
                        sh 'sleep 15'
                    }
                }
            }
        }
    }
}
```

### 9.2 Multibranch Pipelines

A **Multibranch Pipeline** lets Jenkins **automatically discover and create a pipeline for every branch** in a repository that contains a `Jenkinsfile` — instead of manually creating one job per branch.

**How it works:**
1. Jenkins scans the repository for branches containing a `Jenkinsfile`
2. A separate pipeline is auto-created for each matching branch
3. Only the branch with new commits triggers **its own** pipeline — each branch runs independently

**Key features:**
1. **Auto-Discovery** — finds branches with a `Jenkinsfile` and sets up pipelines automatically; also removes pipelines for deleted branches
2. **Automatic Triggering** — pipelines run automatically when changes are pushed to the respective branch
3. **Branch-Specific Pipelines** — each branch can have entirely different CI/CD logic
4. **Support for Pull Requests** — Jenkins can trigger builds on pull request creation and updates

**Example scenario:** Four developers work on branches `dev1`, `dev2`, `dev3`, `dev4`. When `dev1` pushes changes, **only dev1's pipeline runs** — the same applies for `dev2`, `dev3`, `dev4`, independently. Once features merge into a `staging` branch, a push to `staging` triggers a **final integration test** before merging into `main`.

**Demo setup pattern:** a repo with branches `main`, `jenkins`, `feature-1`, `bugfix-1`, each containing its own `Jenkinsfile` → create one Multibranch Pipeline job pointing at the repo → Jenkins auto-detects and builds each branch.

### 9.3 Folders

At scale (thousands of jobs), Jenkins **Folders** act like namespaces in programming — keeping job management structured instead of cluttered.

**Project-based organization:**
```
Project_A/
├── Build_Job
├── Deploy_Job
└── Test_Job
Project_B/
├── Build_Job
└── Deploy_Job
```

**Environment-based organization:**
```
Dev/
├── App_Build
└── App_Deploy
Prod/
├── App_Build
└── App_Deploy
```

Teams commonly get their own folders too — e.g., separate folders for **Developers**, **QA**, **Payments team**, **Billing team** — improving organization and maintainability.

---

## 10. Error Handling and Resilience

Pipelines should fail **gracefully** — a single failed step shouldn't crash everything without cleanup, logging, or notification.

### 10.1 try/catch and currentBuild.result

```groovy
pipeline {
    agent any
    stages {
        stage('Create File') {
            steps {
                script {
                    sh 'echo Hello Jenkins > /tmp/demo_file.txt'
                    echo "File created successfully!"
                }
            }
        }
        stage('Modify File (Simulated Failure)') {
            steps {
                script {
                    try {
                        sh 'some_invalid_command' // This will fail
                        echo "File modified successfully!"
                    } catch (Exception e) {
                        echo "Error in modifying file: ${e.getMessage()}"
                        currentBuild.result = 'FAILURE' // Explicitly fail the pipeline
                    }
                }
            }
        }
        stage('Delete File') {
            steps {
                script {
                    sh 'rm /tmp/demo_file.txt'
                    echo "File deleted successfully!"
                }
            }
        }
    }
    post {
        always {
            echo "Pipeline execution completed!"
            echo "Performing cleanup tasks..."
            sh 'rm -f /tmp/demo_file.txt'
        }
        success {
            echo "All stages executed successfully!"
        }
        failure {
            echo "Pipeline failed due to an error!"
        }
    }
}
```

> **Interview Insight:** Catching an exception inside a `script{}` block does **not** automatically fail the build — Jenkins will happily report SUCCESS unless you explicitly set `currentBuild.result = 'FAILURE'` (or re-throw the exception, or call the `error()` step). This is a very common gotcha in real pipelines.

### 10.2 Retry Mechanism

```groovy
retry(3) {
    sh 'some_command'
}
```

Full example — retrying a flaky download, then validating the outcome:
```groovy
pipeline {
    agent any
    stages {
        stage('Download File') {
            steps {
                script {
                    retry(3) {
                        sh 'curl -o /tmp/sample.txt https://example.com/sample.txt'
                    }
                }
            }
        }
        stage('Process File') {
            steps {
                script {
                    if (fileExists('/tmp/sample.txt')) {
                        echo 'File downloaded successfully, proceeding with processing...'
                    } else {
                        error 'File not found after retries!'
                    }
                }
            }
        }
    }
    post {
        always {
            echo 'Cleaning up workspace...'
            sh 'rm -f /tmp/sample.txt'
        }
    }
}
```

The `error()` step is a built-in Jenkins pipeline step that immediately fails the current stage/pipeline with the given message — often cleaner than manually toggling `currentBuild.result`.

---

## 11. Reports and Test Integration

**Why reports matter:** they let developers and teams **visualize** the status of builds, tests, and code quality metrics without digging through raw console logs.

Three common report types:
1. **Test Results**
2. **Code Coverage**
3. **Build Health**

### 11.1 JUnit + Maven (Java Projects)

**Plugins needed:** `junit` (Jenkins plugin that publishes results) and `surefire` (the Maven plugin that actually runs and reports tests)

```groovy
pipeline {
    agent any
    stages {
        stage('Test') {
            steps {
                sh 'mvn test'                              // Running tests
                junit 'target/surefire-reports/*.xml'      // Publish JUnit reports
            }
        }
    }
}
```

**What does `mvn test` actually do?**
1. **Compiles** the source code (`mvn compile`)
2. **Compiles** the test code (`mvn test-compile`)
3. **Executes** all test cases in the `src/test/java` directory
4. **Generates** a test report at `target/surefire-reports`

**What Maven gives you, generally:** it simplifies builds, manages dependencies, and ensures consistency across environments.

---

## 12. Notifications

Once a build finishes (success or failure), stakeholders need to know. Jenkins supports:
- **Email**
- **Slack**
- **ChatOps** (Microsoft Teams, Mattermost, etc.)

### 12.1 Configuring SMTP for Email Notifications

1. `Manage Jenkins → Configure System`
2. Scroll to **E-mail Notification**
3. Set the SMTP server (e.g., for Gmail: `smtp.gmail.com`)
4. Enable **Use SMTP Authentication**:
   - **Username:** your email address
   - **Password:** an **App Password** (not your regular account password)
5. Click **Test configuration** → send a test email

### 12.2 Using emailext in a Pipeline

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps { echo 'Building project...' }
        }
        stage('Test') {
            steps { echo 'Running tests...' }
        }
    }
    post {
        success {
            emailext subject: "Jenkins Job Successful: ${env.JOB_NAME}",
                body: "The job ${env.JOB_NAME} (#${env.BUILD_NUMBER}) has completed successfully.\nCheck it here: ${env.BUILD_URL}",
                to: 'developer@example.com'
        }
        failure {
            emailext subject: "Jenkins Job Failed: ${env.JOB_NAME}",
                body: "The job ${env.JOB_NAME} (#${env.BUILD_NUMBER}) has failed.\nCheck logs: ${env.BUILD_URL}",
                to: 'developer@example.com'
        }
    }
}
```

---

## 13. End-to-End Project: Jenkins, Docker, and Kubernetes

This is the flagship project pattern from the course: take a **React app on GitHub**, containerize it with **Docker**, push it to **Docker Hub**, and deploy it to **AWS EKS (Kubernetes)** — all orchestrated by **Jenkins**.

### 13.1 The Big Picture

```
Developer -> pushes code -> GitHub
GitHub -> webhook -> Jenkins Pipeline

Jenkins:
  1. Clone repo
  2. Build Docker image
  3. Authenticate with Docker Hub
  4. Push image to Docker Hub
  5. Deploy to Kubernetes (EKS) - kubectl apply

Kubernetes performs a rolling update across pods
```

Jenkins is explicitly the **integration point**. It doesn't care whether the app is monolithic or containerized, or whether deployment targets Kubernetes, Docker Swarm, or a bare server — give it the right **plugins + pipeline configuration** and it can drive any of them.

### 13.2 Jenkins' Role, Concretely

1. **SCM** → automates code fetching (always pulls the latest code)
2. **Build Process** → automates image creation (guarantees a **fresh image** every run)
3. **Docker Authentication** → uses stored Docker Hub credentials
4. **Image Push** → pushes the freshly built image to Docker Hub
5. **Kubernetes Deployment** → automates the release to EKS

### 13.3 Two Implementation Approaches

**Approach 1 — Chained Freestyle Jobs**
```
Job1 (Checkout) -> Job2 (Build) -> Job3 (Push) -> Job4 (Deploy)
```
Each is a separate Freestyle job, chained via "Build after other projects are built."

**Approach 2 — Single Declarative Pipeline** (preferred)
One `Jenkinsfile` handles checkout → build → push → deploy as a single, version-controlled pipeline.

### 13.4 Prerequisites for Connecting Jenkins to AWS EKS

1. **AWS CLI** installed
2. **AWS credentials** — Access Key ID + Secret Access Key
3. **Docker** installed
4. **kubectl** installed and configured

**Install AWS CLI:**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

**Authenticate with AWS:**
```bash
aws configure
# prompts for: Access Key ID, Secret Access Key, Default region (e.g. us-east-1), Output format (json)
```

**Add the EKS cluster to kubeconfig:**
```bash
aws eks --region us-east-1 update-kubeconfig --name jenkinsProject
```

> **Important detail:** both AWS CLI *and* kubectl need authentication. Jenkins jobs run **as the `jenkins` system user**, so credentials must be configured **for that user specifically** — not just for your personal login:
> ```bash
> sudo su jenkins
> aws configure     # run again, this time as the jenkins user
> ```
> Credentials end up in `~/.aws/credentials` (viewable via `vi ~/.aws/credentials`) for whichever user ran `aws configure`.

**Credential placement strategy used in the course:**
- **Docker Hub credentials** → stored inside **Jenkins** (credentials manager)
- **AWS credentials** → stored **on the server itself**, at the system level (for the `jenkins` user)

> **Interview Insight (best practice beyond the notes):** in a real AWS production setup, attaching an **IAM role to the EC2 instance** (an instance profile) is generally preferred over static access keys — no long-lived secrets to store, rotate, or leak. Static keys via `aws configure` are simpler for a lab/course setting but are a legitimate thing to flag as a security tradeoff if asked "how would you do this in production?"

### 13.5 Required Plugins

- **Docker Plugin** (+ Docker API Plugin)
- **Kubernetes Plugin** (+ Kubernetes API Plugin, Kubernetes CLI Plugin, Kubernetes Credentials Plugin)

### 13.6 Understanding the Dockerfile

The course's Dockerfile builds a lightweight React.js container:

1. Uses **Node.js 23.5.0 Alpine** as the base image (Alpine keeps the image small)
2. Copies `package.json` and `package-lock.json` first
3. Installs dependencies (`npm install`)
4. Copies the full application source into the container
5. Exposes **port 3000**
6. Runs `npm start` to launch the React development server

```dockerfile
FROM node:23.5.0-alpine
WORKDIR /react-app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

**Optimization — `.dockerignore`:** excludes files that shouldn't be copied into the image (e.g., `deployment.yaml`, `service.yaml`, `.git`, `node_modules`) — reduces image size and improves build efficiency.

> **Interview Insight:** copying `package.json` / `package-lock.json` and running `npm install` **before** `COPY . .` is a deliberate Docker layer-caching trick. Docker only re-runs `npm install` when the dependency files actually change — not on every source code edit — which dramatically speeds up rebuilds.

### 13.7 Kubernetes Manifests

**`deployment.yaml`** — defines a Deployment (desired state: how many pods, which image, which ports):
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: react-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: react-app
  template:
    metadata:
      labels:
        app: react-app
    spec:
      containers:
      - name: react-app
        image: myrepo/myimage:latest
        ports:
        - containerPort: 80
```
- `replicas: 2` → runs 2 instances (pods) of the app for availability and load distribution
- The container image referenced here **must already exist** in the registry — the build-and-push stages must run *before* this `apply` step

**`service.yaml`** — creates a **LoadBalancer Service**, routing external traffic to pods based on label matching.

**Traffic flow:**
```
External User -> AWS ELB (endpoint) -> Kubernetes Service -> Pod 1 / Pod 2 / Pod 3
```

### 13.8 The Full Jenkins Pipeline

```groovy
pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/your-repo.git', branch: 'main'
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t username/repository:latest .'
            }
        }
        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-credentials',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                }
            }
        }
        stage('Push Image') {
            steps {
                sh 'docker push username/repository:latest'
            }
        }
        stage('Deploy to EKS') {
            steps {
                sh 'kubectl config use-context my-eks-cluster'
                sh 'kubectl apply -f deployment.yaml'
                sh 'kubectl apply -f service.yaml'
            }
        }
    }
}
```

**Creating the Docker Hub credential in Jenkins:**
1. `Manage Jenkins → Manage Credentials`
2. Select **Global Credentials**
3. Click **Add Credentials**
4. Choose **Username and Password**
5. Enter — **ID:** `docker-credentials`; **Username:** Docker Hub username; **Password:** Docker Hub **access token** (not the account password)

**Deployment triggers:**
- **Manual:** click "Build Now" in Jenkins
- **Automated:** a **webhook** fires on every push

**Verifying the deployment:**
```bash
kubectl get pods          # check running pods
kubectl get svc           # check services / get the external LB IP
kubectl get nodes         # check cluster nodes
kubectl get pods -o wide  # more detail per pod
```
Then open the external Load Balancer IP/DNS in a browser to confirm the app is live.

### 13.9 Kubernetes Service Types: NodePort vs. LoadBalancer

| Aspect | NodePort | LoadBalancer |
|---|---|---|
| Exposure | Exposes the service on a specific port on every node | Automatically provisions an external IP/load balancer |
| Access pattern | `nodeIP:port` | External IP directly |
| Typical use | Internal/dev access; clusters without a cloud load balancer | Public-facing production apps on cloud-managed clusters |

```yaml
# NodePort
type: NodePort
nodePort: 30080
```
```yaml
# LoadBalancer
type: LoadBalancer
```

---

## 14. Jenkins Administration

### 14.1 Upgrading Jenkins

1. Go to `Manage Jenkins` — check for Jenkins & security alerts (an upgrade notice appears at the top of the page if one is available)
2. Right-click **changelog** in the alert panel to review what's changing before upgrading
3. Click **download** to get the new `jenkins.war`
4. Check the current version:
   ```bash
   jenkins --version
   # e.g. 2.497
   ```
5. Locate the current `.war` file (default location: `/usr/share/jenkins`):
   ```bash
   ls -lrt *.war
   sudo find . -name '*jenkins.war*'
   ```
6. Copy the new `.war` file to the server:
   ```bash
   scp -i "your-key.pem" jenkins.war ubuntu@<server-ip>:/tmp/
   ```
7. Replace the old `.war` file with the new one (commonly under `/usr/share/java` or `/usr/share/jenkins`, depending on the install method)
8. Restart Jenkins to apply the upgrade:
   ```bash
   sudo systemctl restart jenkins
   ```
9. Confirm the new version: `jenkins --version`

### 14.2 Backup and Restore

**Why back up Jenkins?**
1. **Disaster Recovery (DR)**
2. Ability to **recover an old configuration**

**Backup methods:**
1. **Filesystem snapshot** (e.g., an EBS/VM snapshot)
2. **Plugins** — e.g., the **ThinBackup** plugin
3. **Shell script** — tar up `/var/lib/jenkins` (this directory holds plugins, binaries, dependencies, jobs, and configuration)

**Manual backup script:**
```bash
#!/bin/bash
backup_dir="/backup/jenkins"
mkdir -p $backup_dir
tar -czvf $backup_dir/jenkins_backup_$(date +%F).tar.gz /var/lib/jenkins/
```

**Scheduling it with cron** (e.g., run daily at 2 AM):
```bash
crontab -e
```
```
0 2 * * * /path/to/script.sh
```

**Moving the backup to a remote server:**
```bash
# Simple copy
scp -r /var/lib/jenkins/thinbackup/ user@remote-server:/backup/

# Or incremental transfer (faster on repeat runs)
rsync -avz /var/lib/jenkins/thinbackup/ user@remote-server:/backup/
```

**scp vs. rsync** (a classic interview comparison):

| Feature | scp | rsync |
|---|---|---|
| Transfer Mode | Copies files from source to destination | Synchronizes files, transfers only changes |
| Speed | Slower (copies everything every time) | Faster (only transfers differences) |
| Resume Support | No (must restart the transfer) | Yes (`--partial` allows resuming) |
| Compression | No | Yes (`-z` enables compression) |
| Directory Sync | No (recursively copies but doesn't keep in sync) | Yes (keeps source & destination in sync) |
| Bandwidth Efficient | No (copies entire files) | Yes (transfers only changed parts of files) |
| SSH Support | Yes (built-in) | Yes (uses SSH by default) |
| Deletion Handling | No | Yes (`--delete` removes files at the destination that were removed at the source) |
| Preserves Permissions & Timestamps | Yes (`-p` flag) | Yes (`-a` flag) |

**Manual restore from a backup:**
```bash
# 1. Stop Jenkins
sudo systemctl stop jenkins

# 2. Move existing data out of the way
sudo mv /var/lib/jenkins /var/lib/jenkins_old

# 3. Restore the backup
sudo cp -r /backup/jenkins/* /var/lib/jenkins/

# 4. Fix ownership
sudo chown -R jenkins:jenkins /var/lib/jenkins

# 5. Restart Jenkins
sudo systemctl start jenkins
```

### 14.3 Jenkins Monitoring

**Why monitor Jenkins?**
1. Ensure the server is healthy
2. Understand how resources are being utilized
3. Identify issues before they cause outages

**What to monitor:**
1. **Logs** — system logs
2. **Nodes** — agent health and availability
3. **Executors** — load statistics (how busy each agent/executor is)
4. **Monitoring plugin(s)** — dedicated Jenkins plugins (search "monitoring" in the plugin manager) provide deeper metrics and dashboards

---

## 15. Shared Libraries

A **Jenkins Shared Library** is a reusable, version-controlled set of Groovy scripts that can be used across **multiple** Jenkins pipelines — this is how teams avoid copy-pasting the same pipeline logic into every repo's `Jenkinsfile`.

**Key benefits:**
- **Reusability** — write pipeline functions once, use them in multiple projects
- **Maintainability** — easier updates since logic is stored in a single place
- **Modularity** — organize common pipeline steps into separate, reusable methods
- **Version Control** — stored in a Git repository for tracking and rollback, just like application code

**Typical structure:**
```
testing_repo/
├── vars/                    # Global functions (callable directly as pipeline steps)
│   └── printMessage.groovy  # Example function
└── README.md                # Documentation
```

A function defined in `vars/printMessage.groovy` becomes callable in any pipeline that loads the shared library as simply `printMessage()`.

---

## 16. Quick-Revision Cheat Sheet

**Core facts:**

| Item | Value |
|---|---|
| Default Jenkins port | `8080` |
| Jenkins home directory | `/var/lib/jenkins` |
| Initial admin password | `/var/lib/jenkins/secrets/initialAdminPassword` |
| Minimum RAM | 1 GB (more recommended) |
| Minimum disk space | 4 GB |
| Recommended Java version | 11 or 17 |
| Original name | Hudson (2004) → renamed Jenkins (2011) |
| Plugin ecosystem size | 1,800+ plugins |
| Pipeline-as-code file | `Jenkinsfile` |
| Start/stop/restart | `systemctl start / stop / restart jenkins` |

**One-line definitions:**
- **CI** — frequent automated integration + build + test of code into a shared repo
- **Continuous Delivery** — always deployable; release requires **manual** approval
- **Continuous Deployment** — always deployable; release is **fully automatic**
- **Declarative Pipeline** — structured, validates upfront, fails fast, easier to read
- **Scripted Pipeline** — flexible Groovy, `node{}` blocks, no upfront validation, try/catch error handling
- **SCM Polling** — Jenkins periodically checks the repo for changes
- **Webhook** — repo pushes an event to Jenkins instantly on change
- **Multibranch Pipeline** — auto-discovers and builds every branch with a `Jenkinsfile`
- **Parallel Pipeline** — runs independent stages concurrently to cut total pipeline time
- **Shared Library** — reusable Groovy pipeline code shared across many `Jenkinsfile`s
- **Controller (Master)** — orchestrates jobs, UI, scheduling, logs, plugins
- **Agent (Slave)** — executes the actual work; needs Java installed

**Deployment strategies (Deploy phase of CD):**
- **Rolling update** — gradually swaps old instances for new ones; default Kubernetes Deployment strategy; no downtime, brief mixed-version window
- **Blue-Green** — two full environments; instant cutover/rollback; needs double infrastructure briefly
- **Canary** — release to a small subset first, then ramp up; lowest blast radius, more orchestration complexity

**Command quick-reference:**
```bash
# Jenkins service
sudo systemctl start|stop|restart|enable jenkins

# Initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Backup
tar -czvf backup.tar.gz /var/lib/jenkins/

# Kubernetes
kubectl get pods
kubectl get svc
kubectl get nodes
kubectl apply -f deployment.yaml

# AWS EKS kubeconfig
aws eks --region <region> update-kubeconfig --name <cluster-name>

# Remote build trigger
curl -X POST "http://<JENKINS_IP>:8080/job/<job-name>/build?token=<token>" --user "<user>:<api-token>"
```

---

## 17. Interview Q&A Bank

**Q1. What is Jenkins?**
An open-source automation server used to automate building, testing, and deploying software — the engine that actually executes CI/CD pipelines.

**Q2. What's the difference between Continuous Delivery and Continuous Deployment?**
Both keep code in an always-deployable state via rigorous automated testing. Continuous Delivery requires a manual approval/button-click before release to production. Continuous Deployment removes that manual gate entirely — every change that passes automated tests goes to production automatically.

**Q3. Explain the Jenkins architecture.**
Controller (formerly "Master") + Agents (formerly "Slaves"). The Controller manages jobs, the UI, scheduling, build logs, and plugins. Agents are remote executors that actually run build/test/deploy work, offloading load from the controller for scalability. Agents need Java installed to communicate with the controller.

**Q4. Declarative vs. Scripted pipeline — what's the real difference?**
Declarative uses a fixed `pipeline {}` structure, is easier to read/write, and — critically — validates the entire syntax up front before running anything, so it fails fast on errors. Scripted is raw Groovy inside `node {}` blocks: more flexible and powerful, but with no upfront validation, `try/catch` for error handling instead of `post` blocks, and it requires deeper Groovy knowledge.

**Q5. What is a Jenkinsfile?**
A text file — usually named `Jenkinsfile`, checked into source control alongside the application — that defines the pipeline as code. This is "Pipeline as Code."

**Q6. SCM Polling vs. Webhooks — which is better, and why?**
Webhooks are generally preferred. SCM Polling checks the repo on a timer regardless of whether anything changed — wasted resource use, and it can hit API rate limits at scale. Webhooks push a real-time event to Jenkins the instant a change happens, giving instant builds with zero wasted polling.

**Q7. How do you trigger a Jenkins build from an external system or script?**
Via the Jenkins remote API — an HTTP POST to the job's build URL with a build token and a personal API token, e.g. `curl -X POST ".../build?token=..." --user "user:api-token"`.

**Q8. What's the difference between a credentials domain and a credentials store?**
A **store** is *where* credentials physically live (System, User, Folder-, or Job-specific). A **domain** is how you *organize/scope* credentials (e.g., separate dev vs. prod domains) so the right jobs see the right secrets.

**Q9. How would you speed up a slow pipeline made of independent stages?**
Wrap the independent stages in a `parallel {}` block so they run concurrently instead of sequentially — total pipeline time collapses toward the duration of the single longest stage instead of the sum of all of them.

**Q10. What's a Multibranch Pipeline, and when would you use it?**
A pipeline type that automatically discovers every branch containing a `Jenkinsfile` and creates/maintains a pipeline per branch. Ideal when a team works across many feature/dev branches and you don't want to hand-create a Jenkins job per branch.

**Q11. How does Jenkins handle pipeline failures gracefully?**
Declarative pipelines use `post { always / success / failure }` blocks for guaranteed cleanup and notification regardless of the outcome. Scripted pipelines (or `script{}` blocks inside Declarative) use `try/catch`, and you must explicitly set `currentBuild.result = 'FAILURE'` if you want a caught exception to actually fail the build. `retry(n) { ... }` retries flaky steps (e.g., a network call) up to `n` times before giving up.

**Q12. How do you handle a flaky network call in a pipeline?**
Wrap it in `retry(3) { sh '...' }`. Follow up with a validation step (e.g., `fileExists()`), and use `error('message')` to hard-fail the pipeline if the retries still didn't produce the expected result.

**Q13. How do you deploy to Kubernetes from Jenkins?**
Install the Kubernetes plugin family (Kubernetes, Kubernetes API, Kubernetes CLI, Kubernetes Credentials), authenticate `kubectl`/the AWS CLI on the Jenkins host (specifically as the `jenkins` user), point `kubectl` at the right cluster context (`aws eks update-kubeconfig` for EKS), then run `kubectl apply -f deployment.yaml` / `service.yaml` as pipeline steps — after the image has already been built and pushed.

**Q14. Why do you need to run `aws configure` as the `jenkins` user specifically?**
Jenkins jobs execute as the `jenkins` system user, not as your personal login. AWS CLI credentials are stored per-user (`~/.aws/credentials`), so they must be configured under the `jenkins` user's home directory, or the pipeline won't be able to authenticate to AWS at build time.

**Q15. NodePort vs. LoadBalancer — when do you use each?**
NodePort exposes a service on a static port on every node (`nodeIP:port`) — fine for internal/dev access or clusters without a cloud load balancer. LoadBalancer automatically provisions an external IP via the cloud provider — the standard choice for public-facing production services.

**Q16. How do you back up Jenkins, and what should be backed up?**
Back up `/var/lib/jenkins` — jobs, plugins, credentials/configuration, and build history all live there. Options: a filesystem snapshot, a plugin like ThinBackup, or a scheduled shell script (`tar` + `cron`). Copy the archive off-box with `scp`, or better, `rsync` for incremental/efficient transfers. Restoring means stopping Jenkins, replacing `/var/lib/jenkins` with the backup, fixing ownership (`chown jenkins:jenkins`), and restarting.

**Q17. What's a Jenkins Shared Library, and why use one?**
A separate, version-controlled Groovy repository (with a `vars/` folder of reusable functions) that multiple `Jenkinsfile`s can import — it avoids duplicating pipeline logic across dozens of repos and centralizes maintenance.

**Q18. How do you secure credentials inside a pipeline?**
Use `withCredentials([...])` to inject secrets as scoped environment variables only for the steps inside that block — never hardcode secrets directly in the `Jenkinsfile`. Jenkins also automatically masks known credential values in console output, though that shouldn't be relied on as your only safeguard.

**Q19. Freestyle job vs. Pipeline job — what's the difference, and which is "better"?**
Freestyle jobs are configured through the UI step by step — fine for very simple tasks, but hard to version-control and awkward for complex, multi-stage workflows. Pipeline jobs define the entire process as code (`Jenkinsfile`), versioned alongside the app, and support parallelism, retries, shared libraries, and more — generally the better practice for anything beyond trivial automation.

**Q20. What is a Multi-Configuration (Matrix) job used for?**
Running the same job across a matrix of combinations — e.g., testing against multiple OSes and browser versions from a single job definition, instead of duplicating jobs manually.

**Q21. What are Blue-Green, Canary, and Rolling deployments?**
- **Rolling update** — gradually replaces old instances with new ones a few at a time (Kubernetes' default Deployment strategy); no downtime, but old and new versions briefly run side by side.
- **Blue-Green** — run two full environments (Blue = current, Green = new); switch all traffic at once once Green is verified. Instant cutover/rollback, but needs double the infrastructure during the switch.
- **Canary** — release the new version to a small subset of users/traffic first, watch metrics, then gradually ramp up. Lowest blast radius if something's wrong, but more complex to orchestrate.

**Q22. How would you scale Jenkins for a large organization?**
Distribute work across multiple labeled agents/nodes rather than running everything on the controller, organize jobs with folders, use Shared Libraries to avoid duplicated pipeline logic, and use dedicated agents per environment/team for isolation and specialized tooling.

**Q23. How would you set up a pipeline that only deploys to production after manual approval?**
Use the `input` step inside a stage (Declarative) to pause the pipeline and wait for a human to click "Proceed" — this is the mechanism underlying Continuous Delivery's manual gate, as opposed to Continuous Deployment, which skips it entirely.

**Q24. A build was working yesterday but fails today with no code changes — how do you debug it?**
Check, roughly in this order: (1) the console output for the actual error; (2) whether Jenkins or any plugin auto-updated overnight; (3) whether the job ran on a different agent/node this time (label mismatch, different environment); (4) whether an unpinned upstream dependency moved (e.g., a `latest`-tagged Docker base image or an unpinned npm package); (5) credential or token expiry; (6) disk space on the controller/agent. "No code changes" almost always means the *environment* changed, not the code.

**Q25. Why might a Declarative pipeline "fail immediately" while a Scripted one doesn't, given the same typo?**
Declarative pipelines are validated structurally before any stage executes — a malformed directive (e.g., `stepa` instead of `steps`) is caught during that validation pass and the whole pipeline refuses to start. Scripted pipelines are executed as plain Groovy from top to bottom with no separate validation phase, so the same kind of error surfaces only when that line is actually reached (or may behave differently depending on Groovy's interpretation of it).

---

*Good luck — you've now got the whole course in one place. Skim the Cheat Sheet the morning of your interview, and lean on the "Interview Insight" callouts throughout — those are the distinctions that separate a "book answer" from one that sounds like real hands-on experience.*
