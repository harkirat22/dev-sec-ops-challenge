provider "google" {
  credentials = file(var.gcp_credentials_path)
  project     = var.project_id
  region      = var.region
}

resource "google_container_cluster" "primary" {
  name               = "my-gke-cluster"
  location           = var.region
  initial_node_count = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    tags = ["my-gke-node"]
  }
}
