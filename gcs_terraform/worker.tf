# resource "google_compute_firewall" "worker_fw" {
#   project       = local.temp_project_id
#   name          = "worker-fw"
#   network       = google_compute_network.pe-network.name
#   target_tags   = ["client"]
#   source_ranges = [ var.ip_range ]
#   allow {
#     protocol = "tcp"
#     ports    = ["1-65535"]
#   }
# }

# resource "google_dns_record_set" "centos7-clients-dns" {
#   count        = var.clients
#   project      = var.dns_project_id
#   name         = "centos7-${count.index + 1}.${local.domain}."
#   managed_zone = var.managed_zone_name
#   rrdatas      = [google_compute_instance.centos7-clients[count.index].network_interface[0].access_config[0].nat_ip]
#   ttl          = "300"
#   type         = "A"
# }

# resource "google_dns_record_set" "centos7dev-clients-dns" {
#   count        = var.clients
#   project      = var.dns_project_id
#   name         = "centos7dev-${count.index + 1}.${local.domain}."
#   managed_zone = var.managed_zone_name
#   rrdatas      = [google_compute_instance.centos7-devclients[count.index].network_interface[0].access_config[0].nat_ip]
#   ttl          = "300"
#   type         = "A"
# }

# resource "google_dns_record_set" "debian-clients-dns" {
#   count        = var.clients
#   project      = var.dns_project_id
#   name         = "debian-${count.index + 1}.${local.domain}."
#   managed_zone = var.managed_zone_name
#   rrdatas      = [google_compute_instance.debian-clients[count.index].network_interface[0].access_config[0].nat_ip]
#   ttl          = "300"
#   type         = "A"
# }

# #resource "google_dns_record_set" "debiandev-clients-dns" {
# #  count        = var.clients
# #  project      = var.dns_project_id
# #  name         = "debiandev-${count.index + 1}.${local.domain}."
# #  managed_zone = var.managed_zone_name
# #  rrdatas      = [google_compute_instance.debian-devclients[count.index].network_interface[0].access_config[0].nat_ip]
# #  ttl          = "300"
# #  type         = "A"
# #}

# resource "google_compute_instance" "centos7-clients" {
#   count                     = var.clients
#   allow_stopping_for_update = true
#   project                   = local.temp_project_id
#   zone                      = "australia-southeast1-a"
#   name                      = "centos7-${count.index + 1}"
#   hostname                  = "centos7-${count.index + 1}.${local.domain}"
#   machine_type              = "e2-micro"
#   boot_disk {
#     initialize_params {
#       image = "centos-cloud/centos-7"
#     }
#   }
#   network_interface {
#     network = google_compute_network.pe-network.self_link
#     access_config {
#     }
#   }

#   tags = ["client"]

#   metadata = {
#     "sshKeys"        = "${var.gcp_user}:${file("~/.ssh/google.pub")}"
#     "enable-oslogin" = true
#     "startup-script" = "sleep 30;echo '${google_compute_instance.puppet.network_interface[0].access_config[0].nat_ip} ${google_compute_instance.puppet.hostname}' >> /etc/hosts; curl -k https://${google_compute_instance.puppet.network_interface[0].access_config[0].nat_ip}:8140/packages/current/install.bash | sudo bash -s extension_requests:pp_datacenter=gce extension_requests:pp_role=role::base"
#   }
# }

# resource "google_compute_instance" "centos7-devclients" {
#   count                     = var.clients
#   allow_stopping_for_update = true
#   project                   = local.temp_project_id
#   zone                      = "australia-southeast1-a"
#   name                      = "centos7dev-${count.index + 1}"
#   hostname                  = "centos7dev-${count.index + 1}.${local.domain}"
#   machine_type              = "e2-micro"
#   boot_disk {
#     initialize_params {
#       image = "centos-cloud/centos-7"
#     }
#   }
#   network_interface {
#     network = google_compute_network.pe-network.self_link
#     access_config {
#     }
#   }

#   tags = ["client"]

#   metadata = {
#     "sshKeys"        = "${var.gcp_user}:${file("~/.ssh/google.pub")}"
#     "enable-oslogin" = true
#     "startup-script" = "sleep 30;echo '${google_compute_instance.puppet.network_interface[0].access_config[0].nat_ip} ${google_compute_instance.puppet.hostname}' >> /etc/hosts; curl -k https://${google_compute_instance.puppet.network_interface[0].access_config[0].nat_ip}:8140/packages/current/install.bash | sudo bash -s extension_requests:pp_datacenter=gce extension_requests:pp_role=role::base extension_requests:pp_environment=development"
#   }
# }
# resource "google_compute_instance" "debian-clients" {
#   count                     = var.clients
#   allow_stopping_for_update = true
#   project                   = local.temp_project_id
#   zone                      = "australia-southeast1-a"
#   name                      = "debian-${count.index + 1}"
#   hostname                  = "debian-${count.index + 1}.${local.domain}"
#   machine_type              = "e2-micro"
#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-9"
#     }
#   }
#   network_interface {
#     network = google_compute_network.pe-network.self_link
#     access_config {
#     }
#   }

#   tags = ["client"]

#   metadata = {
#     "sshKeys"        = "${var.gcp_user}:${file("~/.ssh/google.pub")}"
#     "enable-oslogin" = true
#     "startup-script" = "sleep 30;echo '${google_compute_instance.puppet.network_interface[0].access_config[0].nat_ip} ${google_compute_instance.puppet.hostname}' >> /etc/hosts; curl -k https://${google_compute_instance.puppet.network_interface[0].access_config[0].nat_ip}:8140/packages/current/install.bash | sudo bash -s extension_requests:pp_datacenter=gce extension_requests:pp_role=role::base"
#   }
# }
