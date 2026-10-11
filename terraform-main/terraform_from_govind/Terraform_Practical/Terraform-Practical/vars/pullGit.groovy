//This is first step where latest code from the repo is cloned
def call(BRANCH_NAME, CREDENTIALS, GIT_REPO) {
    script {
        echo "Performing git clone."
        sh "pwd"
        git branch: BRANCH_NAME, credentialsId: CREDENTIALS, url: GIT_REPO
    }
}