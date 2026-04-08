# Creamos una IP estática para que el OBS no pierda la conexión
resource "google_compute_address" "static_ip_streaming" {
  name   = "streaming-static-ip-tf"
  region = "europe-southwest1"
}

# La instancia de Compute Engine
resource "google_compute_instance" "servidor_streaming" {
  name         = "servidor-streaming-tfg"
  machine_type = "e2-standard-4"
  zone         = "europe-southwest1-a"
  tags         = ["rtmp-server", "http-server"]

  boot_disk {
    initialize_params { image = "debian-cloud/debian-11" }
  }

  network_interface {
    network = "red-stream-tfg"
    access_config {
      nat_ip = "34.175.126.212" 
    }
  }

  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      apt-get update && apt-get install -y docker.io git

      # 1. Crear estructura de carpetas
      mkdir -p /opt/stream-project/hls
      cd /opt/stream-project

      # 2. Crear el Nginx.conf (el que me has pasado)
      cat <<EOF > nginx.conf
      worker_processes auto;
      events { worker_connections 1024; }
      rtmp {
          server {
              listen 1935;
              chunk_size 4000;
              application live {
                  live on;
                  record off;
                  hls on;
                  hls_path /tmp/hls;
                  hls_fragment 4s;
                  hls_playlist_length 60s;
                  hls_cleanup on;
                  exec ffmpeg -i rtmp://127.0.0.1:1935/live/\$name -c:v libx264 -preset ultrafast -b:v 6500k -f flv /dev/null;
              }
          }
      }
      http {
          sendfile on;
          server {
              listen 80;
              location /hls {
                  alias /tmp/hls;
                  types {
                      application/vnd.apple.mpegurl m3u8;
                      video/mp2t ts;
                  }
                  add_header Cache-Control no-cache;
                  add_header Access-Control-Allow-Origin *;
              }
          }
      }
      EOF

      # 3. Crear el Dockerfile
      cat <<EOF > Dockerfile
      FROM tiangolo/nginx-rtmp
      RUN apt-get update && apt-get install -y ffmpeg
      EOF

      # 4. Construir y lanzar el contenedor de Nginx
      docker build -t nginx-rtmp-tfg .
      docker run -d --name nginx-rtmp -p 1935:1935 -p 80:80 \
        -v /opt/stream-project/nginx.conf:/etc/nginx/nginx.conf \
        -v /opt/stream-project/hls:/tmp/hls \
        nginx-rtmp-tfg

      # 5. Crear el script de Sincronización a Cloud Storage
      cat <<EOF > sync_to_storage.sh
      #!/bin/bash
      LOCAL_DIR="/opt/stream-project/hls"
      BUCKET="gs://tfg-stream-bucket-2026"
      while true; do
        gsutil -m -q cp "\$LOCAL_DIR"/*.ts \$BUCKET/ > /dev/null 2>&1
        if [ -f "\$LOCAL_DIR/TEST.m3u8" ]; then
          gsutil -h "Cache-Control:no-store, no-cache, must-revalidate, max-age=0" \
                 cp "\$LOCAL_DIR/TEST.m3u8" \$BUCKET/TEST.m3u8
        fi
        find "\$LOCAL_DIR" -name "*.ts" -mmin +2 -delete
        sleep 2
      done
      EOF

      chmod +x sync_to_storage.sh
      # Lanzar el sync en segundo plano
      nohup ./sync_to_storage.sh > /dev/null 2>&1 &
    EOT
  }
}

#VM para srt-relay

resource "google_compute_instance" "srt_relay_vm" {
  name         = "srt-relay-tfg"
  machine_type = "e2-medium"
  zone         = "europe-southwest1-a"
  tags         = ["srt-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11" # O la que estés usando
    }
  }

  network_interface {
    network    = google_compute_network.red_stream_tfg.name
    subnetwork = google_compute_subnetwork.subred_madrid.name # Ajusta a tu subred

    access_config {
      nat_ip = google_compute_address.srt_relay_static_ip.address
    }
  }

  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      # 1. Instalar Docker si no está
      apt-get update
      apt-get install -y docker.io git

      # 2. Habilitar servicio
      systemctl enable --now docker

      # 3. Descargar tu config del TFG (Ajusta la URL de tu repo)
      cd /home/pablo_perez92
      git clone https://github.com/tu-usuario/tfg-streaming-platform.git || cd tfg-streaming-platform && git pull

      # 4. Levantar el SRT Relay usando el archivo que subimos antes
      cd /home/pablo_perez92/tfg-streaming-platform/srt-relay
      docker-compose up -d
    EOT
  }
}

# La instancia de Base de Datos (MariaDB)
resource "google_compute_instance" "db_server" {
  name         = "db-server-tfg"
  machine_type = "e2-micro"
  zone         = "europe-southwest1-a"
  tags         = ["db-server"]

  boot_disk {
    initialize_params { 
      image = "debian-cloud/debian-11" 
      size  = 30
    }
  }

  network_interface {
    network    = "red-stream-tfg"
    subnetwork = "subred-madrid"
    network_ip = "10.0.1.7" # Forzamos la IP interna que ya tienes
    access_config {
      # Esto le da IP pública para que puedas entrar por SSH
    }
  }

  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      apt-get update && apt-get install -y docker.io
      systemctl enable --now docker

      # Lanzar el contenedor de MariaDB automáticamente
      # IMPORTANTE: Cambia 'streaming_db' por tu contraseña real
      docker run -d --name mariadb-tfg \
        -p 3306:3306 \
        -e MARIADB_ROOT_PASSWORD=streaming_db \
        -e MARIADB_DATABASE=streaming_platform \
        --restart always \
        mariadb:latest
    EOT
  }
}
