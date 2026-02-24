resource "google_discovery_engine_data_connector" "mail" {
  count    = var.enable_mail_connector ? 1 : 0
  project  = var.project_id
  location = var.location
  provider = google
  # REQUIRED
  collection_id           = var.mail_collection_id
  collection_display_name = var.mail_collection_display_name

  # REQUIRED
  data_source = "google_mail"

  # REQUIRED (periodic sync)
  refresh_interval = var.mail_refresh_interval

  json_params = jsonencode({
  })
  entities {
    entity_name = var.mail_entity.entity_name
    params      = var.mail_entity.params
  }
  connector_modes   = var.workspace_connector_modes
  static_ip_enabled = var.mail_static_ip_enabled
  auto_run_disabled = var.mail_auto_run_disabled
}
