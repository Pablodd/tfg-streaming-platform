resource "google_storage_bucket" "streaming_bucket" {
  name          = "tfg-stream-bucket-2026-tf" # Un nombre único
  location      = "EUROPE-SOUTHWEST1"
  force_destroy = true

  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}
