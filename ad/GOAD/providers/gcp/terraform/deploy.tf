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

  name                = "goad-vm-${each.value.name}-nic"
  location            = google_resource_group.resource_group.location
  resource_group_name = google_resource_group.resource_group.name

  ip_configuration {
    name                          = "goad-vm-${each.value.name}-nic-ipconfig"
    subnet_id                     = google_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.private_ip_address
  }
}

resource "google_windows_virtual_machine" "goad-vm" {
  for_each = var.vm_config

  name                = "goad-vm-${each.value.name}"
  location            = google_resource_group.resource_group.location
  resource_group_name = google_resource_group.resource_group.name
  size                = var.size
  admin_username      = var.username
  admin_password      = "${each.value.password}"
  network_interface_ids = [
    google_compute_network_interface.goad-vm-nic[each.key].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = each.value.windows_sku
    version   = each.value.windows_version # "latest"
  }
}

resource "google_virtual_machine_extension" "goad-vm-ext" {
  for_each = var.vm_config

  name                 = "${each.value.name}-ansible-prep"
  virtual_machine_id   = google_windows_virtual_machine.goad-vm[each.key].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
  {
    "fileUris": ["https://raw.githubusercontent.com/ansible/ansible/38e50c9f819a045ea4d40068f83e78adbfaf2e68/examples/scripts/ConfigureRemotingForAnsible.ps1"],
    "commandToExecute": "net user ansible ${each.value.password} /add /expires:never /y && net localgroup administrators ansible /add && powershell -ExecutionPolicy Unrestricted -File ConfigureRemotingForAnsible.ps1"
  }
  SETTINGS
}