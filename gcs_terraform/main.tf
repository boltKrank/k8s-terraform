locals {
  temp_project_id    = var.random_project_id ? format("%s-%s", var.project_id, local.suffix) : var.project_id
  domain             = var.domain
  suffix             = random_id.suffix.hex
  services           = var.project_apis
}

data "google_organization" "org" {
  organization = var.organization_id
}

resource "random_id" "suffix" {
  byte_length = 2
}

provider "google" {
  project     = local.temp_project_id
  region      = "australia-southeast1"
  zone        = "australia-southeast1-a"
}

resource "google_project" "k8s_test_environment" {
  name            = var.project_name
  project_id      = local.temp_project_id
  org_id          = var.organization_id
  billing_account = var.billing_account
}

resource "google_project_service" "project_api" {
  count                      = length(local.services)
  project                    = local.temp_project_id
  service                    = local.services[count.index]
  disable_dependent_services = true
  depends_on                 = [google_project.demo_environment]
}
