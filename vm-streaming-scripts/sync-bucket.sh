#!/bin/bash

# --- CONFIGURACIÓN ---
LOCAL_DIR="/home/pablo_perez92/stream-project/hls"
BUCKET="gs://tfg-stream-bucket-2026"
PROJECT_ID="stream-cloud-tfg"

# Datos de la Base de Datos (Paso 1)
DB_HOST="10.0.1.5"
DB_USER="root"
DB_PASS="1234" # <--- Cambia esto
DB_NAME="streaming_db"

IS_LIVE=false

echo "🚀 Iniciando monitorización, subida y notificaciones Firebase..."

while true; do
  # 1. Subida de fragmentos de vídeo (.ts)
  gsutil -m -q cp "$LOCAL_DIR"/*.ts $BUCKET/ > /dev/null 2>&1

  # 2. Gestión del Manifiesto (.m3u8) y Lógica de Datos
  if [ -f "$LOCAL_DIR/TEST.m3u8" ]; then
    
    # A. Subir el manifiesto siempre (sin caché)
    gsutil -h "Cache-Control:no-store, no-cache, must-revalidate, max-age=0" \
           cp "$LOCAL_DIR/TEST.m3u8" $BUCKET/TEST.m3u8
    
    # B. Si acaba de empezar el directo
    if [ "$IS_LIVE" = false ]; then
        echo "✅ [$(date +%H:%M:%S)] Directo detectado. Registrando en MariaDB y Firestore..."

        # --- REGISTRO MARIADB ---
        mariadb -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME -e \
        "INSERT INTO sessions (user_id, status, start_time, hls_url) 
         VALUES (1, 'LIVE', NOW(), 'https://storage.googleapis.com/tfg-stream-bucket-2026/TEST.m3u8');"

        # --- REGISTRO FIRESTORE (REST API) ---
        # Registramos el booleano is_live y el timestamp de inicio
        curl -s -X PATCH "https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/live_status/pablo_perez?updateMask.fieldPaths=is_live&updateMask.fieldPaths=startTime&updateMask.fieldPaths=title" \
             -H "Content-Type: application/json" \
             -d "{
               \"fields\": {
                 \"is_live\": {\"booleanValue\": true},
                 \"startTime\": {\"stringValue\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"},
                 \"title\": {\"stringValue\": \"Streaming TFG Pablo\"}
               }
             }" > /dev/null

        if [ $? -eq 0 ]; then
            IS_LIVE=true
            echo "📝 Notificaciones enviadas correctamente."
        else
            echo "❌ Error en las comunicaciones. Reintentando..."
        fi
    fi
    
    echo "🔄 Sincronizado: $(date +%H:%M:%S)"

  else
    # C. Si el streaming finaliza
    if [ "$IS_LIVE" = true ]; then
        echo "🛑 [$(date +%H:%M:%S)] Finalizando. Actualizando MariaDB y Firestore..."

        # --- UPDATE MARIADB ---
        mariadb -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME -e \
        "UPDATE sessions SET status='OFFLINE', end_time=NOW() WHERE user_id=1 AND status='LIVE';"

        # --- UPDATE FIRESTORE (Set is_live a false) ---
        curl -s -X PATCH "https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/live_status/pablo_perez?updateMask.fieldPaths=is_live" \
             -H "Content-Type: application/json" \
             -d "{
               \"fields\": {
                 \"is_live\": {\"booleanValue\": false}
               }
             }" > /dev/null

        IS_LIVE=false
        echo "☁️ Estado Firestore: OFFLINE"
    fi
  fi

  # 3. Limpieza de fragmentos antiguos
  find "$LOCAL_DIR" -name "*.ts" -mmin +2 -delete

  sleep 2
done


