output "mtls_enabled" {
  value = var.enable_mtls
}

output "nomad_server_cert" {
  value = var.enable_mtls ? local.nomad_server_cert : ""
}

output "nomad_server_key" {
  value = var.enable_mtls ? local.nomad_server_key : ""
}

output "nomad_tls_ca" {
  value = var.enable_mtls ? local.nomad_tls_ca : ""
}