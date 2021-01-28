####################################################
#  EXAMPLE INSTANCE OF PRIVATE KUBE CLUSTER MODULE
####################################################

### NETWORK ###
resource "google_compute_network" "circleci_net" {
  name                    = "${var.basename}-net"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "cluster_sn" {
  name          = "${var.basename}-cluster-net"
  ip_cidr_range = var.cluster_subnet_cidr
  network       = google_compute_network.circleci_net.id
}

resource "google_compute_subnetwork" "vm_sn" {
  name          = "${var.basename}-vm-net"
  ip_cidr_range = var.vm_subnet_cidr
  network       = google_compute_network.circleci_net.id
}

resource "google_compute_subnetwork" "nomad_sn" {
  name          = "${var.basename}-nomad-net"
  ip_cidr_range = var.nomad_subnet_cidr
  network       = google_compute_network.circleci_net.id
}

# GKE cluster settings
module "kube_private_cluster" {

  # General
  source      = "./private_kubernetes"
  unique_name = var.basename
  project_id  = var.project_id
  location    = var.project_loc
  labels = {
    circleci = true
  }
  node_tags = []

  # Node pool configuration
  preemptible_nodes  = var.preemptible_k8s_nodes
  nodes_machine_spec = var.node_spec
  node_min           = var.node_min
  node_max           = var.node_max
  node_pool_cpu_max  = var.node_pool_cpu_max
  node_pool_ram_max  = var.node_pool_ram_max
  initial_nodes      = var.initial_nodes
  node_auto_repair   = var.node_auto_repair
  node_auto_upgrade  = var.node_auto_upgrade

  # Network configuration
  allowed_external_cidr_blocks   = var.allowed_cidr_blocks
  enable_nat                     = var.enable_nat
  enable_bastion                 = var.enable_bastion
  privileged_bastion             = var.privileged_bastion
  enable_istio                   = var.enable_istio
  enable_intranode_communication = var.enable_intranode_communication
  enable_dashboard               = var.enable_dashboard
  private_endpoint               = var.private_k8s_endpoint
  private_vms                    = var.private_vms
  vm_subnet_cidr                 = var.vm_subnet_cidr

  network_uri = google_compute_network.circleci_net.self_link
  subnet_uri  = google_compute_subnetwork.cluster_sn.self_link
}

resource "google_storage_bucket" "data_bucket" {
  name = "${var.basename}-data"

  force_destroy = var.force_destroy

  labels = {
    circleci = true
  }
}

resource "google_compute_firewall" "allow_cluster_network" {
  name        = "allow-cluster-network-${var.basename}"
  description = "${var.basename} firewall rule for CircleCI Server cluster component"
  network     = google_compute_network.circleci_net.self_link
  priority    = 980

  allow { protocol = "icmp" }
  allow { protocol = "tcp" }
  allow { protocol = "udp" }

  source_ranges = [google_compute_subnetwork.cluster_sn.ip_cidr_range, google_compute_subnetwork.nomad_sn.ip_cidr_range, google_compute_subnetwork.vm_sn.ip_cidr_range]
}

resource "google_compute_firewall" "restrict_egress_to_cluster" {
  name        = "deny-traffic-to-cluster-${var.basename}"
  description = "${var.basename} firewall rule for CircleCI Server cluster component"
  network     = google_compute_network.circleci_net.self_link
  direction   = "EGRESS"
  priority    = 1000

  deny { protocol = "icmp" }
  deny { protocol = "tcp" }
  deny { protocol = "udp" }

  destination_ranges = [google_compute_subnetwork.cluster_sn.ip_cidr_range]
}

resource "google_compute_firewall" "allow_cluster_network_egress" {
  name        = "allow-cluster-egress-${var.basename}"
  description = "${var.basename} firewall rule for CircleCI Server cluster component"
  network     = google_compute_network.circleci_net.self_link
  direction   = "EGRESS"
  priority    = 980
  target_tags = ["gke-node"]

  allow { protocol = "icmp" }
  allow { protocol = "tcp" }
  allow { protocol = "udp" }
}

resource "google_compute_firewall" "nomad_grpc_egress" {
  name        = "grpc-nomad-cluster-traffic-${var.basename}"
  description = "${var.basename} firewall rule for CircleCI Server cluster component"
  network     = google_compute_network.circleci_net.self_link
  direction   = "EGRESS"
  priority    = 900
  target_tags = ["nomad"]

  allow {
    protocol = "tcp"
    ports    = ["3000", "4647", "8585"]
  }

  destination_ranges = [google_compute_subnetwork.cluster_sn.ip_cidr_range]
}

resource "google_compute_firewall" "vm_ephemeral_egress" {
  name        = "ephemeral-vm-cluster-traffic-${var.basename}"
  description = "${var.basename} firewall rule for CircleCI Server cluster component"
  network     = google_compute_network.circleci_net.self_link
  direction   = "EGRESS"
  priority    = 900
  target_tags = ["docker-machine"]

  allow {
    protocol = "tcp"
    ports    = ["32768-61000"]
  }

  destination_ranges = [google_compute_subnetwork.cluster_sn.ip_cidr_range]
}
