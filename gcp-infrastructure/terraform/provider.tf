terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = "Stream-cloud-tfg" # Pon aquí el ID de tu proyecto de GCP
  region  = "europe-southwest1"
  zone    = "europe-southwest1-a"
}
