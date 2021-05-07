resource "google_dns_record_set" "frontend-test" {
  project      = var.dns_project_id
  name         = "k8s.${local.domain}."
  managed_zone = var.managed_zone_name
  rrdatas      = [google_compute_instance.k8s.network_interface[0].access_config[0].nat_ip]
  ttl          = "300"
  type         = "A"
}

resource "google_compute_instance" "k8s" {
  project      = local.temp_project_id
  zone         = "australia-southeast1-b"
  name         = "k8s"
  hostname     = "k8s.${local.domain}"
  machine_type = "n1-standard-4"
  boot_disk {
    initialize_params {
      size  = 30
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }
  network_interface {
    network = google_compute_network.k8s-network.self_link
    access_config {
    }
  }
  lifecycle {
    ignore_changes = [attached_disk]
  }

  tags = ["k8s-master", "k8s-server"]

  metadata = {
    "sshKeys"        = "${var.gcp_user}:${file("~/.ssh/google.pub")}"
    "enable-oslogin" = false
  }

#   provisioner "remote-exec" {
#     connection {
#       host        = self.network_interface[0].access_config[0].nat_ip
#       type        = "ssh"
#       user        = var.gcp_user
#       timeout     = "500s"
#       private_key = file(var.gcp_user_private_ssh_key)
#     }
#     inline = [
#       "cat > /tmp/pe.conf <<EOF\n${data.template_file.pe_conf.rendered}EOF",
#       "chmod 755 /tmp/init-scripts/pe.sh",
#       "/tmp/init-scripts/pe.sh ${var.console_password}"
#     ]
#   }
}