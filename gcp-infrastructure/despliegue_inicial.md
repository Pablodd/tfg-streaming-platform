docker ps
docker exec servidor-final-tfg tail -f /tmp/ffmpeg.log
docker restart servidor-final-tfg
rm -rf /home/pablo_perez92/stream-project/hls/*
ls -lh /home/pablo_perez92/stream-project/hls
gsutil -m rm gs://tfg-stream-bucket-2026/**
gsutil iam ch allUsers:objectViewer gs://tfg-stream-bucket-2026
gsutil cors set cors.json gs://tfg-stream-bucket-2026
nohup ./sync-bucket.sh > sync.log 2>&1 &
pkill -f sync-bucket.sh
gcloud compute url-maps invalidate-cdn-cache cdn-load-balancer-streaming --path "/*"
gcloud run services list --region all
gcloud run deploy portal-web-tfg --source . --region europe-southwest1
Ctrl + F5 (en el navegador)
ps aux | grep sync-bucket.sh
gsutil -m rsync -r -d /home/pablo_perez92/stream-project/hls gs://tfg-stream-bucket-2026/
tail -f sync_output.log
"# Mata todos los procesos que tengan el nombre del script
pkill -f sync-bucket.sh

# Por si acaso, mata también cualquier comando de gcloud storage que se haya quedado trabado
pkill -f ""gcloud storage"""
