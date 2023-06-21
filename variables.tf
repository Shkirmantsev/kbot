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

variable "TLS_ALGORITHM" {
  description = "The algorithm to use for the private key."
  default     = "ECDSA"
  type        = string
}

variable "TLS_EDCSA_CURVE" {
  description = "The curve to use for ECDSA"
  default     = "P256"
  type        = string
}