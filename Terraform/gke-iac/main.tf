terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.40"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# -----------------------------
# Enable needed APIs (idempotent)
# -----------------------------
resource "google_project_service" "services" {
  for_each = toset([
    "container.googleapis.com", # GKE
    "compute.googleapis.com",   # VPC, firewall, etc.
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ])
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

# -----------------
# Networking (VPC)
# -----------------
resource "google_compute_network" "vpc" {
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Public subnet (nodes live here so NodePort is reachable)
resource "google_compute_subnetwork" "public" {
  name          = "${var.name}-public-subnet"
  ip_cidr_range = var.public_cidr
  network       = google_compute_network.vpc.id
  region        = var.region
}

# ----------------------
# Firewall (least-priv)
# ----------------------
# (Optional) SSH to nodes only from your IP if you need it
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.name}-allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.admin_cidr]
  direction     = "INGRESS"
  target_tags   = ["${var.name}-node"]
}

# Allow ONLY HTTP to NodePort 30080 (your earlier NGINX)
resource "google_compute_firewall" "allow_http_nodeport" {
  name    = "${var.name}-allow-http-30080"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["30080"]
  }

  source_ranges = var.http_ingress_cidrs
  direction     = "INGRESS"
  target_tags   = ["${var.name}-node"]
}

# Allow all egress (nodes -> internet) to pull images, etc.
resource "google_compute_firewall" "allow_egress" {
  name    = "${var.name}-allow-egress"
  network = google_compute_network.vpc.name
  direction = "EGRESS"

  destination_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "all"
  }
}

# ----------------
# GKE (Standard)
# ----------------
resource "google_service_account" "nodes_sa" {
  account_id   = "${var.name}-nodes"
  display_name = "GKE nodes SA"
}

resource "google_container_cluster" "cluster" {
  name     = "${var.name}-gke"
  location = var.region

  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.public.name

  remove_default_node_pool = true
  initial_node_count       = 1

  # VPC-native (recommended)
  ip_allocation_policy {}

  # Restrict control plane access (API) to your IP
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.admin_cidr
      display_name = "admin"
    }
  }

  # Reduce cost noise from logs/metrics while learning (adjust as needed)
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  depends_on = [google_project_service.services]
}

resource "google_container_node_pool" "pool" {
  name       = "${var.name}-pool"
  location   = var.region
  cluster    = google_container_cluster.cluster.name
  node_count = 4

  node_config {
    machine_type   = var.node_machine_type   # e.g., "e2-small"
    preemptible    = var.preemptible_nodes   # cheap for testing
    disk_size_gb   = 20
    disk_type      = "pd-balanced"
    service_account = google_service_account.nodes_sa.email
    oauth_scopes   = ["https://www.googleapis.com/auth/cloud-platform"]
    tags           = ["${var.name}-node"]    # matches firewall target_tags
    metadata = {
      disable-legacy-endpoints = "true"
    }
    labels = {
      env = var.env
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = 4
    max_node_count = 4
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  depends_on = [google_container_cluster.cluster]
}

# -------------
# Outputs
# -------------
output "cluster_name" {
  value = google_container_cluster.cluster.name
}
output "region" {
  value = var.region
}
output "vpc_name" {
  value = google_compute_network.vpc.name
}
