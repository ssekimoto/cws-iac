##########################################################
# Terraform & Google Provider
##########################################################
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.56"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.56"
    }
  }
}


provider "google" {
  # Service Account Keyは使わず、ADCやインパーソネーションなどで認証
  # credentials = file(var.gcp_credentials_file)  # ←コメントアウト

  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

##########################################################
# 必要なAPIをまとめて有効化
#   VPC, NAT, Cloud Workstations に必要なもの
##########################################################
locals {
  required_services = [
    "compute.googleapis.com",
    "workstations.googleapis.com",
  ]
}

resource "google_project_service" "enabled_apis" {
  for_each           = toset(local.required_services)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

##########################################################
# 1. VPCの作成 & Subnet
##########################################################
resource "google_compute_network" "main_vpc" {
  name                    = var.vpc_name
  project                 = var.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main_subnet" {
  name                  = var.subnet_name
  project               = var.project_id
  region                = var.region
  network               = google_compute_network.main_vpc.self_link
  ip_cidr_range         = var.subnet_cidr
  private_ip_google_access = true
}

##########################################################
# 2. Cloud Router & NAT
##########################################################
resource "google_compute_router" "main_router" {
  name    = var.router_name
  network = google_compute_network.main_vpc.self_link
  region  = var.region
  project = var.project_id
}

resource "google_compute_router_nat" "main_nat" {
  name                               = var.nat_name
  router                             = google_compute_router.main_router.name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  depends_on = [google_compute_router.main_router]
}

##########################################################
# 3. Cloud Workstations
#   - Cluster (クラスタ)
#   - Config (デフォルトコンテナ使用)
#   - Workstation (実際のインスタンス)
#
#   ここでカスタムコンテナを指定しない => デフォルトイメージになる
##########################################################

# 3-1) Workstation Cluster
resource "google_workstations_workstation_cluster" "main_cluster" {
  provider = google-beta
  workstation_cluster_id = var.workstations_cluster_id
  project      = var.project_id
  location     = var.region  # 例: asia-northeast1
  display_name = "Demo Workstations Cluster (Tokyo)"

  network    = google_compute_network.main_vpc.id
  subnetwork = google_compute_subnetwork.main_subnet.id

  depends_on = [google_project_service.enabled_apis]
}

# 3-2) Workstation Config (デフォルトコンテナを使用 → containerブロックを省略)
resource "google_workstations_workstation_config" "main_config" {
  # Betaプロバイダを使用
  provider = google-beta

  # 必須: プロジェクト, ロケーション
  project  = var.project_id
  location = var.region

  # **重要**: 以下2つが必須フィールド
  #   - workstation_cluster_id
  #   - workstation_config_id
  workstation_cluster_id = google_workstations_workstation_cluster.main_cluster.workstation_cluster_id
  workstation_config_id  = var.workstations_config_id

  # 表示名(任意)
  display_name = "Demo Workstations Config"

  # 上位レベルでアイドル時・稼働時のタイムアウト指定 (現行は enable_audit_agent などは無い)
  idle_timeout    = "3600s"   # アイドル1時間で停止
  running_timeout = "10800s"  # 上限3時間で停止

  # VM設定は「host_gce_instance」ブロックで指定
   host {
    gce_instance {
      machine_type                = "e2-standard-4"
      boot_disk_size_gb           = 35
      disable_public_ip_addresses = true
    }
  }
}



# 3-3) Workstation
resource "google_workstations_workstation" "my_workstation" {
  provider = google-beta
  project  = var.project_id
  location = var.region

  # 以前: cluster_id = ...
  # 今は:
  workstation_cluster_id = google_workstations_workstation_cluster.main_cluster.workstation_cluster_id
  workstation_config_id  = google_workstations_workstation_config.main_config.workstation_config_id
  workstation_id         = var.workstation_id

  display_name = "My Workstation"
}


