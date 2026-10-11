def call (folder_name, job_base_name, variable_folder_name) {
	script {
		def workspacePath = "/var/lib/jenkins/workspace/$job_base_name/$folder_name"
        echo "Workspace Path: ${workspacePath}"
        def variablePath = "/var/lib/jenkins/workspace/$job_base_name/$variable_folder_name"
        echo "variablePath: ${variablePath}"
        dir(workspacePath) {
            echo "Current Directory: ${pwd()}"
            sh ' ls -lart'
            sh ' pwd'
            sh "cp '$variablePath/state-lock.tf' '$workspacePath'"
            sh "terraform init "
            sh "terraform plan --var-file='$variablePath/terraform.tfvars'"
            sh "terraform apply --var-file='$variablePath/terraform.tfvars' --auto-approve"
        }
	}
}