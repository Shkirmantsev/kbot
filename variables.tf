variable "GOOGLE_PROJECT" {
  type        = string
  description = "GCP project name"
}

variable "GOOGLE_REGION" {
  type        = string
  description = "GCP region to use"
}

variable "GKE_MACHINE_TYPE" {
  type        = string
  description = "Machine type"
}

variable "GKE_NUM_NODES" {
  type        = number
  description = "GKE nodes number"
}

variable "GKE_CLUSTER_NAME" {
  type        = string
  description = "GKE cluster name"
}

variable "GKE_POOL_NAME" {
  type        = string
  description = "GKE pool name"
}

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