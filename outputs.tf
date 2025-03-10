##########################################################
# 出力 (例)
##########################################################
output "vpc_name" {
  description = "VPC Name"
  value       = google_compute_network.main_vpc.name
}

output "workstations_cluster_id" {
  description = "Created Workstations Cluster ID"
  value       = google_workstations_workstation_cluster.main_cluster.id
}

output "workstations_config_id" {
  description = "Created Workstations Config ID"
  value       = google_workstations_workstation_config.main_config.id
}
