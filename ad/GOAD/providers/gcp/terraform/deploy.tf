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
  network_interface {
    network = "GOAD"
       access_config {
      nat_ip = each.value.private_ip_address
    }
  }
}
