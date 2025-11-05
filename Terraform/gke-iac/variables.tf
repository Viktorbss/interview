variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-central2"
}

variable "name" {
  description = "Resource name prefix"
  type        = string
  default     = "startup"
}

variable "env" {
  description = "Environment label"
  type        = string
  default     = "dev"
}

variable "public_cidr" {
  description = "CIDR for the public subnet"
  type        = string
  default     = "10.20.0.0/24"
}

variable "admin_cidr" {
  description = "Your public IP/CIDR for API (& optional SSH) access"
  type        = string
}

variable "http_ingress_cidrs" {
  description = "Who can reach NodePort :30080"
  type        = list(string)
  default     = ["0.0.0.0/0"] # tighten to your /32 when ready
}

variable "node_machine_type" {
  description = "GCE machine type for GKE nodes"
  type        = string
  default     = "e2-small" # 2 vCPU, 2GB RAM (cheap, OK for demo)
}

variable "preemptible_nodes" {
  description = "Use preemptible nodes to save credits"
  type        = bool
  default     = true
}
