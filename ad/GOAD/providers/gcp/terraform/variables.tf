variable "location" {
  type    = string
  default = "us-central1"  // Using a GCP region code
}

variable "size" {
  type    = string
  default = "e2-standard-2"  // Using a GCP machine type
}


resource "google_compute_network" "vpc" {
  name                    = "goad-virtual-network"
  auto_create_subnetworks = false  // Disable automatic subnetwork creation
  routing_mode            = "REGIONAL"  // Set routing mode to REGIONAL
  mtu                     = 1460
}

resource "google_compute_subnetwork" "goad-subnet" {
  name          = "goad-vm-subnet"
  ip_cidr_range = "192.168.56.0/24"
  region        = var.location  // Set region directly in the subnetwork
  network       = google_compute_network.vpc.self_link
}

