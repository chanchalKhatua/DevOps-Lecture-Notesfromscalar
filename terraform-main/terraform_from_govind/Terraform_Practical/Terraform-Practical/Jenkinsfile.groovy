@Library("TerraformScripts") _

properties([
  parameters([
    choice(name: 'ACCOUNT', choices: ['Dev','Prod'], description: 'Select the Account in which the terraform template needs to be deployed'),
    choice(name: 'ACTION', choices: ['Create-stack','Delete-stack'], description: 'Select the choice if you want create or delete the terraform stack'),
    string(defaultValue: 'Folder_Name', name: 'FOLDER_NAME', trim: true, description: 'Enter the name of the terraform resource folder name which is in the Git/ BitBucket Repo' ),
    string(defaultValue: 'Folder_Name', name: 'VARIABLE_FOLDER_NAME', trim: true, description: 'Enter the name of the terraform variables folder name which is in the Git/ BitBucket Repo' )
   ])
])

pipeline{
  agent any
  environment {
    PROD_ACC_NO=''
    PROD_IAM_ROLE_NAME=''
  }
  stages {  
    stage("Execution Stage") {   
      steps {
        script {
          if (params.ACCOUNT == 'Prod') {
            withAWS(role: "${env.PROD_IAM_ROLE_NAME}", roleAccount: "${env.PROD_ACC_NO}"){
              if (params.ACTION == 'Create-stack') {
                echo "Action: Create-stack"
                try {
                  terraformApply("${params.FOLDER_NAME}", "${JOB_BASE_NAME}", "${params.VARIABLE_FOLDER_NAME}")
                }
                catch (err) {
                  echo "Error: ${err}"
                  error("${STAGE_NAME} Stage Failed in ${JOB_BASE_NAME} Jenkins Job")
                }
              } 
              else if (params.ACTION == 'Delete-stack') {
                echo "Action: Delete-stack"
                isDelete = input message: "Do you want to delete ${params.FOLDER_NAME}",
                              parameters: [[$class: 'ChoiceParameterDefinition', name: 'Delete-Stack', choices: ['Yes', 'No'], description: "Are you sure you want to delete ${params.FOLDER_NAME}"]]
                if (isDelete == 'Yes') {
                  terraformDestroy("${params.FOLDER_NAME}", "${JOB_BASE_NAME}", "${params.VARIABLE_FOLDER_NAME}")
                }
                else if (isDelete == 'No') {
                  echo "${params.FOLDER_NAME} is not deleted"
                }
                else {
                  echo "Error: ${err}"
                  error("${STAGE_NAME} Stage Failed in ${JOB_BASE_NAME} Jenkins Job")
                }
              } 
              else {
                error("Invalid action specified: ${params.ACTION}")
              }
            }
          }
          else if (params.ACCOUNT == 'Dev') {
           if (params.ACTION == 'Create-stack') {
              echo "Action: Create-stack"
              try {
                terraformApply("${params.FOLDER_NAME}", "${JOB_BASE_NAME}", "${params.VARIABLE_FOLDER_NAME}")
              }
              catch (err) {
                echo "Error: ${err}"
                error("${STAGE_NAME} Stage Failed in ${JOB_BASE_NAME} Jenkins Job")
              }
            }
            else if (params.ACTION == 'Delete-stack') {
              echo "Action: Delete-stack"
              isDelete = input message: "Do you want to delete ${params.FOLDER_NAME}",
                            parameters: [[$class: 'ChoiceParameterDefinition', name: 'Delete-Stack', choices: ['Yes', 'No'], description: "Are you sure you want to delete ${params.FOLDER_NAME}"]]
              if (isDelete == 'Yes') {
                terraformDestroy("${params.FOLDER_NAME}", "${JOB_BASE_NAME}", "${params.VARIABLE_FOLDER_NAME}")
              }
              else if (isDelete == 'No') {
                echo "${params.FOLDER_NAME} is not deleted"
              }
              else {
                echo "Error: ${err}"
                error("${STAGE_NAME} Stage Failed in ${JOB_BASE_NAME} Jenkins Job")
              }
            }
            else {
                error("Invalid action specified: ${params.ACTION}")
            }  
          }
          else {
            error("Invalid environment specified")
          }
        }
      }
    }
  }
  post {
    always {
        cleanWs notFailBuild: true
    }
  }
}