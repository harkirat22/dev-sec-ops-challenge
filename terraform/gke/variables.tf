variable "project_id" {
  description = "The ID of the project in which to provision resources."
  default     = ""
}

variable "region" {
  description = "The region to deploy to."
  default     = "us-central1"
}

variable "gcp_credentials_path" {
  description = "Path to the GCP credentials file."
  default     = "/home/circleci/gcp_cred_config.json"
}
