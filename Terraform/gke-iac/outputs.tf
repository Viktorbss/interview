output "cluster_name" {
  value = google_container_cluster.cluster.name
}

output "region" {
  value = var.region
}

output "vpc_name" {
  value = google_compute_network.vpc.name
}

output "gcloud_connect" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.cluster.name} --zone ${var.zone} --project ${var.project_id}"
}