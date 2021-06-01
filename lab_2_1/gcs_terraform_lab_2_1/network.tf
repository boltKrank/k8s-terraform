resource "google_compute_firewall" "k8s-master" {
  project     = local.temp_project_id
  name        = "k8s-master"
  network     = google_compute_network.k8s-network.name
  target_tags = ["k8s-master"]
  allow {
    protocol = "tcp"
    ports    = ["2379","2380","6443","8090","8091","8472","10250","10251","10252","10255"]
  }
}

resource "google_compute_firewall" "k8s-ssh" {
  project       = local.temp_project_id
  name          = "k8s-ssh"
  network       = google_compute_network.k8s-network.name
  target_tags   = ["k8s-master"]
  source_ranges = [ var.ip_range ]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_network" "k8s-network" {
  project                 = local.temp_project_id
  name                    = "k8s-network"
  auto_create_subnetworks = "true"
  depends_on              = [google_project.k8s_test_environment, google_project_service.project_api]
}