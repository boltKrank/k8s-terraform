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
  rrdatas      = [google_compute_instance.worker[count.index].network_interface[0].access_config[0].nat_ip]
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

  provisioner "file" {
    connection {
      host        = self.network_interface[0].access_config[0].nat_ip
      type        = "ssh"
      user        = var.gcp_user
      timeout     = "500s"
      private_key = file(var.gcp_user_private_ssh_key)
    }
    source = "files"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    connection {
      host        = self.network_interface[0].access_config[0].nat_ip
      type        = "ssh"
      user        = var.gcp_user
      timeout     = "500s"
      private_key = file(var.gcp_user_private_ssh_key)
    }
    inline = [
      #Docker CE install
      "sudo apt-get clean",
      "sudo rm -rf /var/lib/apt/lists",
      "sudo mkdir /var/lib/apt/lists",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu",
      "sudo apt-mark hold docker-ce",
      "sudo systemctl status docker --no-pager",
      #k8s install
      "curl -fsSL  https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/google-archive-keyring.gpg",
      "echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/google-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main\" | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y kubelet=1.14.5-00 kubeadm=1.14.5-00 kubectl=1.14.5-00",
      "sudo apt-mark hold kubelet kubeadm kubectl",
      #"sudo kubeadm init --pod-network-cidr=10.244.0.0/16",
      #"mkdir -p $HOME/.kube",
      #"sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      #"sudo chown $(id -u):$(id -g) $HOME/.kube/config",
      #Need to export the kubeadm join command to the workers
      "kubectl version"
    ]
  }

}