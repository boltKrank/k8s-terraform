output "puppet" {
  value = [google_compute_instance.puppet.network_interface[0].access_config[0].nat_ip]
}