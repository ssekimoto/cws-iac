variable "project_id" {
  type        = string
  description = "Terraformを適用するGCPプロジェクトID (既存)"
}

variable "region" {
  type        = string
  default     = "asia-northeast1"
  description = "VPC, Cloud Workstationsのリージョン"
}

variable "vpc_name" {
  type        = string
  default     = "demo-vpc"
}

variable "subnet_name" {
  type        = string
  default     = "demo-subnet"
}

variable "subnet_cidr" {
  type        = string
  default     = "10.0.0.0/24"
}

variable "router_name" {
  type        = string
  default     = "demo-router"
}

variable "nat_name" {
  type        = string
  default     = "demo-nat"
}

variable "workstations_cluster_id" {
  type        = string
  default     = "demo-workstations-cluster"
  description = "Workstations cluster short ID"
}

variable "workstations_config_id" {
  type        = string
  default     = "demo-workstations-config"
}

variable "workstation_id" {
  type        = string
  default     = "demo-workstation"
}

variable "workstations_service_account" {
  type        = string
  default     = ""
  description = "Workstations VMが使用するサービスアカウント(任意)"
}

# credentialsを使わない例:
# variable "gcp_credentials_file" {
#   type        = string
#   default     = ""
#   description = "SAキーを使わない場合は空"
# }
