terraform {
  backend "gcs" {
    bucket = "cis410-wesley-tf-state"
    prefix = "week8"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}