resource "google_discovery_engine_data_connector" "calendar" {
  count                   = var.enable_calendar_connector ? 1 : 0
  project                 = var.project_id
  location                = var.location
  provider                = google
  collection_id           = var.calendar_collection_id
  collection_display_name = var.calendar_collection_display_name

  data_source = "google_calendar"

  refresh_interval = var.calendar_refresh_interval

  json_params = jsonencode({
  })
  entities {
    entity_name = var.calendar_entity.entity_name
    params      = var.calendar_entity.params
  }
  connector_modes   = var.workspace_connector_modes
  static_ip_enabled = var.calendar_static_ip_enabled
  auto_run_disabled = var.calendar_auto_run_disabled
}
