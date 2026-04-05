resource "google_firestore_database" "database" {
  name                    = "(default)"
  location_id             = "europe-southwest1"
  type                    = "FIRESTORE_NATIVE"
  concurrency_mode        = "OPTIMISTIC"
  app_engine_integration_mode = "DISABLED"
}
