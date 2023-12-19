output "ubuntu-jumpbox-ip" {
  value = google_linux_virtual_machine.jumpbox.public_ip_address
}
