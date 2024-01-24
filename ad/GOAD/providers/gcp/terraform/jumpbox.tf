resource "google_compute_address" "ubuntu_public_ip" {
  name = "ubuntu-public-ip"
}

resource "google_compute_network_interface" "ubuntu_jumbox_nic" {
  name = "ubuntu-jumbox-nic"
  network = google_compute_network.virtual_network.self_link
  subnetwork = google_compute_subnetwork.subnet.self_link
  access_config {
    nat_ip = google_compute_address.ubuntu_public_ip.address
  }
}

resource "google_compute_instance" "jumpbox" {
  name         = "ubuntu-jumpbox"
  machine_type = var.size
  zone         = var.location

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = google_compute_network.virtual_network.self_link
    subnetwork = google_compute_subnetwork.subnet.self_link
    network_ip = "192.168.56.100"
  }

  metadata = {
    ssh-keys = "jumpbox:${tls_private_key.ssh.public_key_openssh}"
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.ssh.private_key_pem}' > ../ssh_keys/ubuntu-jumpbox.pem && chmod 600 ../ssh_keys/ubuntu-jumpbox.pem"
  }
}
