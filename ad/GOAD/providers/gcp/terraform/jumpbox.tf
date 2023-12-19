resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_public_ip" "ubuntu_public_ip" {
  name                = "ubuntu-public-ip"
  location            = google_resource_group.resource_group.location
  resource_group_name = google_resource_group.resource_group.name
  allocation_method   = "Static"
}

resource "google_compute_network_interface" "ubuntu_jumbox_nic" {
  name                = "ubuntu-jumbox-nic"
  location            = google_resource_group.resource_group.location
  resource_group_name = google_resource_group.resource_group.name

  ip_configuration {
    name                          = "ubuntu-jumbox-nic-ipconfig"
    subnet_id                     = google_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "192.168.56.100"
    public_ip_address_id          = google_public_ip.ubuntu_public_ip.id
  }
}

resource "google_linux_virtual_machine" "jumpbox" {
  name                = "ubuntu-jumpbox"
  resource_group_name = google_resource_group.resource_group.name
  location            = google_resource_group.resource_group.location
  size                = var.size
  admin_username      = var.jumpbox_username
  network_interface_ids = [
    google_compute_network_interface.ubuntu_jumbox_nic.id,
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.jumpbox_username
    public_key = tls_private_key.ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.ssh.private_key_pem}' > ../ssh_keys/ubuntu-jumpbox.pem && chmod 600 ../ssh_keys/ubuntu-jumpbox.pem"
  }
}
