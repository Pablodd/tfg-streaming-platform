#!/bin/bash

# Configuración
LOCAL_DIR="/home/pablo_perez92/stream-project/hls"
BUCKET="gs://tfg-stream-bucket-2026"
DB_NAME="db-streaming"
DOC_ID="live_stream_01" # ID único para este directo en la base de datos

echo "Iniciando subida forzada con registro en Firestore..."

# Al empezar, marcamos el directo como ONLINE en Firestore
gcloud firestore documents update projects/stream-cloud-tfg/databases/$DB_NAME/documents/streams/$DOC_ID \
    --set-fields="status=online,last_update=$(date -u +%Y-%m-%dT%H:%M:%SZ),url=$BUCKET/TEST.m3u8,title=Mi Directo TFG"

while true; do
  # 1. Subida rápida de fragmentos .ts
  gsutil -m -q cp "$LOCAL_DIR"/*.ts $BUCKET/ > /dev/null 2>&1

  # 2. Subida del manifiesto .m3u8 (sin caché)
  if [ -f "$LOCAL_DIR/TEST.m3u8" ]; then
    gsutil -h "Cache-Control:no-store, no-cache, must-revalidate, max-age=0" \
           cp "$LOCAL_DIR/TEST.m3u8" $BUCKET/TEST.m3u8
    
    # 3. Actualizamos el 'timestamp' en Firestore para que el Player sepa que sigue vivo
    gcloud firestore documents update projects/stream-cloud-tfg/databases/$DB_NAME/documents/streams/$DOC_ID \
        --set-fields="last_update=$(date -u +%Y-%m-%dT%H:%M:%SZ)" --quiet > /dev/null 2>&1

    echo "Sincronizado y Firestore actualizado: $(date +%H:%M:%S)"
  fi

  # 4. Limpieza de disco local
  find "$LOCAL_DIR" -name "*.ts" -mmin +2 -delete

  sleep 2
done
