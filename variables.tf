variable "GITHUB_TOKEN" {
  description = "GitHub access token for read, edit and creation repositories"
  type        = string
}

variable "GITHUB_OWNER" {
  description = "GitHub user (account)"
  type        = string
}

variable "FLUX_GITHUB_REPO" {
  description = "The name of the Git repository to be created (for flux configuration)"
  type        = string
}