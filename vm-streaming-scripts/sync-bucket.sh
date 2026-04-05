#!/bin/bash

# Carpeta local y destino
LOCAL_DIR="/home/pablo_perez92/stream-project/hls"
BUCKET="gs://tfg-stream-bucket-2026"

echo "Iniciando subida forzada..."

while true; do
  # 1. Subimos todos los .ts que existan actualmente
  # Usamos 'cp -n' para no resubir lo que ya está, pero asegurar que lo nuevo suba
  gsutil -m -q cp "$LOCAL_DIR"/*.ts $BUCKET/ > /dev/null 2>&1

  # 2. Subimos el manifiesto SIEMPRE, machacando el anterior y sin caché
  if [ -f "$LOCAL_DIR/TEST.m3u8" ]; then
    gsutil -h "Cache-Control:no-store, no-cache, must-revalidate, max-age=0" \
           cp "$LOCAL_DIR/TEST.m3u8" $BUCKET/TEST.m3u8
    echo "Sincronizado: $(date +%H:%M:%S)"
  fi

  # 3. Borramos fragmentos muy viejos de la VM para que no se llene el disco
  # (Opcional: solo si llevas horas emitiendo)
  find "$LOCAL_DIR" -name "*.ts" -mmin +2 -delete

  sleep 2
done
