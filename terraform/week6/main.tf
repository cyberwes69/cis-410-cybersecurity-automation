terraform {
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

resource "google_storage_bucket" "bucket1" {
  name     = "${var.project_id}-bucket1"
  location = "US"
}

resource "google_storage_bucket" "bucket2" {
  name     = "${var.project_id}-bucket2"
  location = "US"
}

