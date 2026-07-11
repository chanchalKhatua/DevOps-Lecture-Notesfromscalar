    terraform {
      required_providers {
        local = {
          source  = "hashicorp/local"
          version = "2.5.2" # Use the latest stable version
        }
      }
    }


    resource "local_file" "my_local_file" {
      filename = "/home/user/workspace/project_info.txt" # Specify the full path or relative path
      file_permission = "0644" # Read/write for owner, read-only for others
      content  = <<EOT
Project Name: ${var.project_name}
Owner Email: ${var.owner_email}
Team Members: ${join(", ", var.team_members)}
EOT
    }

output "owner_uppercase_email" {
  value = upper(var.owner_email)
  description = "Upper case user email"
}

output "team_size" {
  value = length(var.team_members)
  description = "Size of team "
}

output "project_summary" {
  description = "Summary of the project"
  value = "Project ${var.project_name} managed by ${var.owner_email} with ${length(var.team_members)} members"

}
