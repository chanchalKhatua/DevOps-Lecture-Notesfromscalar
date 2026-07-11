variable "tag_keys" {
  description = "The list of tag keys to use for the resources"
  type        = list(string)
}

variable "tag_values" {
  description = "The list of tag values to use for the resources"
  type        = list(string)
}