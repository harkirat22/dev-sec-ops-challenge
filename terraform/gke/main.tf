
terraform {
  backend "gcs" {
    bucket  = "tf-backend-1018"
    prefix  = "terraform/state"
  }
}
provider "google" {
  credentials = file(var.gcp_credentials_path)
  project     = var.project_id
  region      = var.region
}


# create VPC
resource "google_compute_network" "vpc" {
  name                    = "vpc1"
  auto_create_subnetworks = false
}

# Create Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "subnet1"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.0.0.0/24"
}

resource "google_container_cluster" "primary" {
  name               = "gke-test-cluster"
  location           = var.region
  network                  = google_compute_network.vpc.name
  subnetwork               = google_compute_subnetwork.subnet.name
  remove_default_node_pool = false  
  initial_node_count = 1

  node_config {
    disk_size_gb = 10
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
