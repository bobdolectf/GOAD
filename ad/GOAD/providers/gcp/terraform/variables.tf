variable "location" {
  type    = string
  default = "westeurope"
}

resource "google_resource_group" "resource_group" {
  name     = "GOAD"
  location = var.location
}

resource "google_virtual_network" "virtual_network" {
  name                = "goad-virtual-network"
  address_space       = ["192.168.0.0/16"]
  location            = google_resource_group.resource_group.location
  resource_group_name = google_resource_group.resource_group.name
}

resource "google_subnet" "subnet" {
  name                 = "goat-vm-subnet"
  resource_group_name  = google_resource_group.resource_group.name
  virtual_network_name = google_virtual_network.virtual_network.name
  address_prefixes     = ["192.168.56.0/24"]
}

variable "size" {
  type    = string
  default = "Standard_B2s"
}

variable "username" {
  type    = string
  default = "goadmin"
}

variable "password" {
  description = "Password of the windows virtual machine admin user"
  type    = string
  default = "goadmin"
}

variable "jumpbox_username" {
  type    = string
  default = "goad"
}
