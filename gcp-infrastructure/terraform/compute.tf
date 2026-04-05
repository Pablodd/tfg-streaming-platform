# Creamos una IP estática para que el OBS no pierda la conexión
resource "google_compute_address" "static_ip_streaming" {
  name   = "streaming-static-ip-tf"
  region = "europe-southwest1"
}

# La instancia de Compute Engine
resource "google_compute_instance" "streaming_server" {
  name         = "servidor-streaming-tfg-tf"
  machine_type = "e2-standard-4"
  zone         = "europe-southwest1-a"

  # Etiquetas para que el Firewall deje pasar el tráfico
  tags = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12" # Basado en tu salida anterior
      size  = 20 # 20GB es suficiente para el SO y Docker
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet_madrid.id

    access_config {
      nat_ip = google_compute_address.static_ip_streaming.address
    }
  }

  metadata = {
    # Aquí podríamos meter el script de instalación de Docker automática más adelante
    description = "Servidor de streaming replicado vía Terraform"
  }
}
