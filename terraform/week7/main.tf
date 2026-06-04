terraform {
  backend "gcs" {
    bucket = "cis410-wesley-tfstate"
    prefix = "week7"
  }

  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}

# VPC

resource "google_compute_network" "vpc" {
  name                    = "week7-vpc"
  auto_create_subnetworks = false
}

# Subnet

resource "google_compute_subnetwork" "subnet" {
  name          = "week7-subnet"
  ip_cidr_range = "10.10.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc.id
}

# Firewall Rule

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}