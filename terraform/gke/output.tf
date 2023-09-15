output "cluster_endpoint" {
  description = "The IP address of the cluster master."
  value       = google_container_cluster.primary.endpoint
}

output "cluster_name" {
  value = google_container_cluster.primary.name
  description = "The name of the GKE cluster."
}

output "cluster_zone" {
  value = google_container_cluster.primary.location
  description = "The zone of the GKE cluster."
}