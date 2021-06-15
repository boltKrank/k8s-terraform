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
      "sudo kubeadm init --pod-network-cidr=10.244.0.0/16",
      "mkdir -p $HOME/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config",
      #Need to export the kubeadm join command to the workers
      "kubectl version"
    ]
  }


}

# NOTES: Exporting master info for kubeadmin join.

# google_compute_instance.k8s (remote-exec):   mkdir -p $HOME/.kube
# google_compute_instance.k8s (remote-exec):   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# google_compute_instance.k8s (remote-exec):   sudo chown $(id -u):$(id -g) $HOME/.kube/config

# google_compute_instance.k8s (remote-exec): You should now deploy a pod network to the cluster.
# google_compute_instance.k8s (remote-exec): Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
# google_compute_instance.k8s (remote-exec):   https://kubernetes.io/docs/concepts/cluster-administration/addons/

# google_compute_instance.k8s (remote-exec): Then you can join any number of worker nodes by running the following on each as root:

# google_compute_instance.k8s (remote-exec): kubeadm join 10.152.0.2:6443 --token 1lh5pd.q61rq0ca4uqn1f7t \
# google_compute_instance.k8s (remote-exec):     --discovery-token-ca-cert-hash sha256:0d99b45b4b953d509aab7785f55d238a4ffa657e91d7486a855683ae5266c3bb
# google_compute_instance.k8s: Still creating... [2m50s elapsed]
# google_compute_instance.k8s: Creation complete after 2m50s [id=projects/sa-demo-303011-feab/zones/australia-southeast1-b/instances/k8s]
# google_dns_record_set.frontend-test: Creating...
# google_dns_record_set.frontend-test: Creation complete after 1s [id=projects/sa-demo-303011/managedZones/boltkrank-zone/rrsets/k8s.gcp.boltkrank.com./A]