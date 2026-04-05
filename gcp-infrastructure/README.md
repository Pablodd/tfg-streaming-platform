# 🏗️ Infraestructura Cloud - TFG Streaming

Este documento detalla la configuración de Google Cloud Platform (GCP) para replicar el entorno.

## 🌐 Redes y Conectividad (VPC)
* **VPC Name:** `red-stream-tfg` (o la que crearas).
* **Subnet:** `europe-southwest1` (Madrid).
* **IPs Públicas:** * VM Streaming: `34.175.126.212` (Estática reservada).
    * Load Balancer / CDN: `34.8.142.83`.

## 🔥 Reglas de Firewall
| Nombre | Puerto | Protocolo | Función |
|--------|--------|-----------|---------|
| allow-rtmp | 1935 | TCP | Ingesta de vídeo desde OBS |
| allow-http | 80 | TCP | Acceso web y HLS |
| allow-https | 443 | TCP | Acceso web seguro |
| allow-ssh | 22 | TCP | Administración remota |

## 📦 Almacenamiento (Cloud Storage)
* **Bucket:** `gs://tfg-stream-bucket-2026/`
* **Configuración:** Multiregional, acceso público habilitado, CORS configurado para el dominio del portal.

## 🚀 Cloud Run (Frontend)
* **Servicio:** `portal-web-stream`
* **Imagen:** GCR.io/proyecto/imagen-player:latest
* **Variables de entorno:** Configuración de Firestore integrada.
