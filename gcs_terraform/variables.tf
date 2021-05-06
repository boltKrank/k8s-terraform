variable "project_name" {
  description = "name of the project"
}

variable "credentials_file_path" {
  description = "Service account key path default to ADC path"
  #default =  "~/.config/gcloud/application_default_credentials.json"
  default     = "C:\\Users\\Tom\\AppData\\Roaming\\gcloud\\application_default_credentials.json"
}

variable "project_id" {
  description = "Organization Seed Project Project ID"
}

variable "random_project_id" {
  description = "Add random suffix to project ID for testing purposes"
  default     = "true"
}

variable "organization_id" {
  description = "GCP Organization ID"
}

variable "billing_account" {
  description = "The ID of the billing account to associate this project with"
}

variable "gcp_user" {
  description = "GCP user"
}

variable "gcp_user_public_ssh_key" {
  default = "~/.ssh/google.pub"
}

variable "gcp_user_private_ssh_key" {
  default = "~/.ssh/google"
}

variable "domain" {
  description = "The dns zone for this environment"
}

variable "managed_zone_name" {
  description = "Managed zone name"
}

variable "ip_range" {
  description = "Allowed IP range for SSH/RDP"
}

variable "dns_project_id" {
  description = "The project hosting master dns for the domain"
  default     = "sa-demo-303011"
}

variable "project_apis" {
  description = "List of APIs to enable."
  type        = list(string)

  default = [
    "cloudkms.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "admin.googleapis.com",
  ]
}


