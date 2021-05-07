resource "google_compute_firewall" "k8s-master" {
  project     = local.temp_project_id
  name        = "k8s-master"
  network     = google_compute_network.k8s-network.name
  target_tags = ["k8s-master"]
  allow {
    protocol = "tcp"
    ports    = ["5432", "443", "8140", "8142", "8143", "8170", "4433", "8123", "8080", "8081", "8000", "5432", "62658"]
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