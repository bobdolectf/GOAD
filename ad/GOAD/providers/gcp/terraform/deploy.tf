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
    disk               = string
  }))

  default = {
    "dc01" = {
      name               = "dc01"
      windows_sku        = "2019-Datacenter"
      windows_version    = "2019.0.20181122"
      private_ip_address = "192.168.56.10"
      password           = "8dCT-DJjgScp"
      disk               = "windows-cloud/windows-2019-core"
    }
    "dc02" = {
      name               = "dc02"
      windows_sku        = "2019-Datacenter"
      windows_version    = "2019.0.20181122"
      private_ip_address = "192.168.56.11"
      password           = "NgtI75cKV+Pu"
      disk               = "windows-cloud/windows-2019-core"
    }
    "dc03" = {
      name               = "dc03"
      windows_sku        = "2016-Datacenter"
      windows_version    = "2016.127.20181122"
      private_ip_address = "192.168.56.12"
      password           = "Ufe-bVXSx9rk"
      disk               = "windows-cloud/windows-2016-core"
    }
    "srv02" = {
      name               = "srv02"
      windows_sku        = "2019-Datacenter"
      windows_version    = "2019.0.20181122"
      private_ip_address = "192.168.56.22"
      password           = "NgtI75cKV+Pu"
      disk               = "windows-cloud/windows-2019-core"
    }
    "srv03" = {
      name               = "srv03"
      windows_sku        = "2016-Datacenter"
      windows_version    = "2016.127.20181122"
      private_ip_address = "192.168.56.23"
      password           = "978i2pF43UJ-"
      disk               = "windows-cloud/windows-2019-core"
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
      image = each.value.disk
    }
  }
  network_interface {
    network = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.goad_subnet.name
    access_config {}
  }
}

resource "local_file" "script" {
  filename = "script.ps1"
  content = local-exec(var.script_url, { depends_on = [google_compute_instance.goad-vm] })
}

resource "google_compute_copy_file" "deploy_script" {
  source_file = local_file.script.filename
  destination_path = "C:\\scripts\\script.ps1"
  compute_engine = google_compute_instance.goad-vm.self_link
}

resource "google_compute_instance" "startup_script" {
  provisioner "remote-exec" {
    inline = [
      "net user ansible each.value.password /add /expires:never /y && net localgroup administrators ansible /add && powershell -exec bypass -c "(New-Object Net.WebClient).Proxy.Credentials=[Net.CredentialCache]::DefaultNetworkCredentials;iwr("https://raw.githubusercontent.com/ansible/ansible/38e50c9f819a045ea4d40068f83e78adbfaf2e68/examples/scripts/ConfigureRemotingForAnsible.ps1")\'|\'iex""
    ]
  }
}
