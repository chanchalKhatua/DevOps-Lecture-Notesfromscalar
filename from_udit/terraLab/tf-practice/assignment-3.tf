resource "random_id" "suffix" {
    byte_length = 8
}

provider "github" {
  token = var.github_token
}

resource "github_repository" "gh_repo" {
    name        = "my-terraform-repo-${random_id.suffix.hex}"
    visibility  = "private"         # ✅ use 'visibility', not 'private = true'
    auto_init   = true              # ✅ creates repo with initial README.md
    has_issues = true
}