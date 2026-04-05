# La Red VPC principal
resource "google_compute_network" "vpc_network" {
  name                    = "red-stream-tfg-tf" # Le añado -tf para no chocar con la actual
  auto_create_subnetworks = false
}

# La Subred de Madrid
resource "google_compute_subnetwork" "subnet_madrid" {
  name          = "subred-madrid-tf"
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-southwest1"
  network       = google_compute_network.vpc_network.id
}

# Regla para RTMP (Ingesta de OBS)
resource "google_compute_firewall" "allow_rtmp" {
  name    = "permitir-rtmp-tf"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["1935"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Regla para Web (HTTP/S para el Player y HLS)
resource "google_compute_firewall" "allow_web" {
  name    = "permitir-web-tf"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Regla para SSH seguro (Google IAP)
resource "google_compute_firewall" "allow_ssh_iap" {
  name    = "permitir-ssh-google-iap-tf"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

#Red para srt-relay
resource "google_compute_address" "srt_relay_static_ip" {
  name   = "srt-relay-static-ip"
  region = "europe-southwest1"
}

#Regla para firewall

resource "google_compute_firewall" "permitir_srt_relay" {
  name    = "permitir-srt-relay"
  network = google_compute_network.red_stream_tfg.name # Ajusta al nombre de tu red

  allow {
    protocol = "udp"
    ports    = ["10080"]
  }

  allow {
    protocol = "tcp"
    ports    = ["1935", "1985", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["srt-server"]
}
