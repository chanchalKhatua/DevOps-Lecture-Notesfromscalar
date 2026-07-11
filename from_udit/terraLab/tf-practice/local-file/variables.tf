variable "project_name" {
  description = "project name"
  type        = string
}

variable "owner_email" {
  description = "owner_email"
  type        = string
}

variable "team_members" {
  description = "team_members"
  type        = list(string)
}