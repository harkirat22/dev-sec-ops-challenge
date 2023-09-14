output "cluster_endpoint" {
  description = "The IP address of the cluster master."
  value       = google_container_cluster.primary.endpoint
}
