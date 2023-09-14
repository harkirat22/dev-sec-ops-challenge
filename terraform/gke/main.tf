provider "google" {
  credentials = file(var.gcp_credentials_path)
  project     = var.project_id
  region      = var.region
}

resource "google_container_cluster" "primary" {
  name               = "gke-test-cluster"
  location           = var.region
  initial_node_count = 1


  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]
    disk_size_gb = 10
    metadata = {
      disable-legacy-endpoints = "true"
    }

    tags = ["my-gke-node"]
  }
}
