resource "google_firestore_database" "streaming_db" {
  name                    = "db-streaming"
  location_id             = "europe-southwest1"
  type                    = "FIRESTORE_NATIVE"
  concurrency_mode        = "PESSIMISTIC"
  deletion_protection_enabled = false
}
