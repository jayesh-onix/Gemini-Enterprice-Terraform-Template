resource "google_discovery_engine_data_connector" "drive" {
  count                   = var.enable_drive_connector ? 1 : 0
  project                 = var.project_id
  location                = var.location
  provider                = google
  collection_id           = var.drive_collection_id
  collection_display_name = var.drive_collection_display_name

  data_source = "google_drive"

  refresh_interval = var.drive_refresh_interval

  json_params = jsonencode({
  })

  entities {
    entity_name = var.drive_entity.entity_name
    params      = var.drive_entity.params
  }
  connector_modes   = var.workspace_connector_modes
  static_ip_enabled = var.drive_static_ip_enabled
  auto_run_disabled = var.drive_auto_run_disabled
}
