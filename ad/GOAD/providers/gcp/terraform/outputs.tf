output "ubuntu-jumpbox-ip" {
  value = google_compute_instance.jumpbox.public_ip_address
}
