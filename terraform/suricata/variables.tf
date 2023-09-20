variable "kube_config_path" {
  description = "Path to the GCP credentials file."
  default     = "/home/circleci/.kube/config"
}

variable "docker_tag" {
  description = "The tag for the custom suricator docker image"
  type        = string
  default     = "latest"
}
