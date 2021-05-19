output "k8s-master" {
  value = [google_compute_instance.k8s.network_interface[0].access_config[0].nat_ip]
}

output "workers" {
  value = {
    for 
  }
}