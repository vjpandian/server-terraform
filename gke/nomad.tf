module "nomad" {
  source = "./nomad"

  basename                = var.basename
  source_image            = var.nomad_source_image
  enable_mtls             = var.enable_mtls
  network_name            = google_compute_network.circleci_net.name
	subnet_name             = google_compute_subnetwork.nomad_sn.name
  nomad_count             = var.nomad_count
  nomad_sa_access         = var.nomad_sa_access
  project_id              = var.project_id
  project_loc             = var.project_loc
  ssh_allowed_cidr_blocks = var.allowed_cidr_blocks
  ssh_enabled             = var.nomad_ssh_enabled
  cluster_subnet_cidr     = google_compute_subnetwork.cluster_sn.ip_cidr_range
}
