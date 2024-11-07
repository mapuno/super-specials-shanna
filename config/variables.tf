# variables.tf
variable "github_token" {
  description = "GitHub Token with repo access"
  type        = string
  sensitive   = true
}