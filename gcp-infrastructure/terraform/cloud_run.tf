resource "google_cloud_run_v2_service" "player_service" {
  name     = "portal-web-tfg-tf" # Nuevo nombre para no pisar el actual
  location = "europe-southwest1"

  template {
    containers {
      image = "europe-southwest1-docker.pkg.dev/stream-cloud-tfg/cloud-run-source-deploy/portal-web-tfg@sha256:6c1850b74f00f50c8c4863ca7d2d4ab9bb670e855078d81533884940150b1ae1"
      
      # Aquí es donde inyectaremos variables en el futuro para que el JS sea dinámico
      env {
        name  = "PROJECT_ID"
        value = "stream-cloud-tfg"
      }
    }
  }

  ingress = "INGRESS_TRAFFIC_ALL"
}

# Hacer que el Player sea público (para que cualquiera pueda entrar a ver el streaming)
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  name     = google_cloud_run_v2_service.player_service.name
  location = google_cloud_run_v2_service.player_service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
