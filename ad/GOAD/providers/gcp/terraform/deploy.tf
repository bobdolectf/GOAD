terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.10.0"
    }
  }
}

provider "google-beta" {
  project     = "GOAD"
  region      = "us-central1"
  zone        = "us-central1-c"
}

variable "vm_config" {
  type = map(object({
    name               = string
    windows_sku        = string
    windows_version    = string
    private_ip_address = string
    password           = string
  }))

  default = {
    "dc01" = {
      name               = "dc01"
      windows_sku        = "2019-Datacenter"
      windows_version    = "2019.0.20181122"
      private_ip_address = "192.168.56.10"
      password           = "8dCT-DJjgScp"
    }
    "dc02" = {
      name               = "dc02"
      windows_sku        = "2019-Datacenter"
      windows_version    = "2019.0.20181122"
      private_ip_address = "192.168.56.11"
      password           = "NgtI75cKV+Pu"
    }
    "dc03" = {
      name               = "dc03"
      windows_sku        = "2016-Datacenter"
      windows_version    = "2016.127.20181122"
      private_ip_address = "192.168.56.12"
      password           = "Ufe-bVXSx9rk"
    }
    "srv02" = {
      name               = "srv02"
      windows_sku        = "2019-Datacenter"
      windows_version    = "2019.0.20181122"
      private_ip_address = "192.168.56.22"
      password           = "NgtI75cKV+Pu"
    }
    "srv03" = {
      name               = "srv03"
      windows_sku        = "2016-Datacenter"
      windows_version    = "2016.127.20181122"
      private_ip_address = "192.168.56.23"
      password           = "978i2pF43UJ-"
    }
  }
}


resource "google_compute_network_interface" "goad-vm-nic" {
  for_each = var.vm_config

  name          = "goad-vm-${each.value.name}-nic"
  subnetwork    = google_compute_subnetwork.subnet.self_link
}

resource "google_compute_instance" "goad-vm" {
  for_each = var.vm_config
  name         = "goad-vm-${each.value.name}"
  machine_type = var.size
  zone         = "us-central1-a"  # Replace with your preferred zone
  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-server-2022-dc-core"  # Adjust image reference if needed
    }
  }
}

  network_interface {
    network = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.subnet.self_link
  }


resource "google_compute_instance_metadata" "goad-vm-metadata" {
  for_each = var.vm_config
  instance = google_compute_instance.goad-vm[each.key].self_link
  metadata = {
    "ansible-user" = "ansible"  // Set Ansible user
    "ansible-password" = each.value.password  // Set Ansible password
  }
}
