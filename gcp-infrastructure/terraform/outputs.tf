# --- OUTPUTS DEL SRT RELAY (Nodo de Entrada) ---

output "srt_ingest_url_obs" {
  value       = "srt://${google_compute_instance.srt_relay.network_interface.0.access_config.0.nat_ip}:10080?streamid=#!::h=live/stream01,m=publish"
  description = "URL para configurar en OBS (Emisión desde el Auditorio)"
}

output "srt_playback_url_vlc" {
  value       = "srt://${google_compute_instance.srt_relay.network_interface.0.access_config.0.nat_ip}:10080?streamid=#!::h=live/stream01,m=request"
  description = "URL para recibir en VLC o vMix vía SRT"
}

output "srt_dashboard_url" {
  value       = "http://${google_compute_instance.srt_relay.network_interface.0.access_config.0.nat_ip}:8080/console/"
  description = "Panel de control web para ver estadísticas del SRT"
}


# --- OUTPUTS DEL SERVIDOR STREAMING (Nodo de Distribución) ---

output "rtmp_ingest_url" {
  value       = "rtmp://${google_compute_instance.servidor_streaming.network_interface.0.access_config.0.nat_ip}/live"
  description = "Punto de publicación RTMP (Si decides enviar desde vMix a este servidor)"
}

output "hls_playback_url" {
  value       = "http://${google_compute_instance.servidor_streaming.network_interface.0.access_config.0.nat_ip}/hls/TEST.m3u8"
  description = "URL del streaming HLS para el reproductor web (Directo desde la VM)"
}

output "cloud_storage_hls_url" {
  value       = "https://storage.googleapis.com/tfg-stream-bucket-2026/TEST.m3u8"
  description = "URL pública de la CDN (Cloud Storage) para los espectadores"
}

output "servidor_streaming_ssh" {
  value       = "gcloud compute ssh ${google_compute_instance.servidor_streaming.name} --zone=${google_compute_instance.servidor_streaming.zone}"
  description = "Comando rápido para entrar por SSH al servidor principal"
}
