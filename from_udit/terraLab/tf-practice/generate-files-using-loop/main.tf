terraform {
    required_providers {
    local = {
        source  = "hashicorp/local"
        version = "2.5.2" # Use the latest stable version
    }
    }
}

resource "local_file" "local_file" {
  for_each = var.users
  filename = "welcome_${each.key}.txt"
  content = each.value
  file_permission = "0644"
  // Other attributes
}


output "generated_files" {
  value = [for k in keys(var.users) : "welcome_${k}.txt"]
}
