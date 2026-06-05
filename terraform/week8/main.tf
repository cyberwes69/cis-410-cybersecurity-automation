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

resource "google_cloud_run_v2_service" "flask_app" {

  name     = "cis410-flask-app"

  location = var.region


  template {

    containers {

      image = var.container_image   # full Artifact Registry path from tfvars

      ports { container_port = 5000 }


      resources {

        limits = { cpu = "1", memory = "512Mi" }

      }

    }


    scaling {

      min_instance_count = 0   # scale to zero when idle — no cost

      max_instance_count = 3   # lab ceiling

    }


    # Connect Cloud Run to the VPC from Week 7

    vpc_access {

      network_interfaces {

        network    = data.terraform_remote_state.week7.outputs.vpc_name

        subnetwork = data.terraform_remote_state.week7.outputs.subnet_name

      }

      egress = "PRIVATE_RANGES_ONLY"

    }

  }

}

resource "google_cloud_run_v2_service_iam_member" "public_access" {

  name     = google_cloud_run_v2_service.flask_app.name

  location = var.region

  role     = "roles/run.invoker"

  member   = "allUsers"

}