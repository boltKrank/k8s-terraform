resource "google_compute_firewall" "worker_fw" {
  project       = local.temp_project_id
  name          = "worker-fw"
  network       = google_compute_network.k8s-network.name
  target_tags   = ["k8s-worker"]
  source_ranges = [ var.ip_range ]
  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }
}

resource "google_dns_record_set" "worker-pod-dns" {
  count        = var.workers
  project      = var.dns_project_id
  name         = "worker-${count.index + 1}.${local.domain}."
  managed_zone = var.managed_zone_name
  rrdatas      = [google_compute_instance.worker-[count.index].network_interface[0].access_config[0].nat_ip]
  ttl          = "300"
  type         = "A"
}

resource "google_compute_instance" "worker" {
  count                     = var.workers
  allow_stopping_for_update = true
  project                   = local.temp_project_id
  zone                      = "australia-southeast1-a"
  name                      = "worker-${count.index + 1}"
  hostname                  = "worker-${count.index + 1}.${local.domain}"
  machine_type              = "n1-standard-4"
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }
  network_interface {
    network = google_compute_network.k8s-network.self_link
    access_config {
    }
  }

  tags = ["worker"]

  metadata = {
    "sshKeys"        = "${var.gcp_user}:${file("~/.ssh/google.pub")}"
    "enable-oslogin" = false
  }
}