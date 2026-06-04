output "vpc_name" {
  value = google_compute_network.vpc.name
}

output "subnet_name" {
  value = google_compute_subnetwork.subnet.name
}

output "firewall_name" {
  value = google_compute_firewall.allow_ssh.name
}