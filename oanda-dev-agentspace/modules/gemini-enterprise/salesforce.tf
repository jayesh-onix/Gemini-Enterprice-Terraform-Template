
data "google_secret_manager_secret" "salesforce_secrets" {
  for_each  = var.enable_salesforce_connector ? toset(["client_id", "client_secret"]) : toset([])
  provider  = google
  project   = var.project_id
  secret_id = each.key == "client_id" ? "ONIX_SALESFORCE_ZOWIE_KEY" : "ONIX_SALESFORCE_ZOWIE_SECRET"
}

resource "google_secret_manager_secret_iam_member" "allow_discovery_engine_read_salesforce" {
  for_each  = var.enable_salesforce_connector ? toset(["client_id", "client_secret"]) : toset([])
  provider  = google
  project   = var.project_id
  secret_id = data.google_secret_manager_secret.salesforce_secrets[each.key].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_project_service_identity.discovery_engine_sa[0].email}"
}

resource "google_discovery_engine_data_connector" "salesforce" {
  count    = var.enable_salesforce_connector ? 1 : 0
  provider = google
  project  = var.project_id
  location = var.location

  # Collection ID is required - auto-created by the connector
  collection_id = var.salesforce_collection_id

  collection_display_name = var.salesforce_collection_display_name

  # Data source type
  data_source = "salesforce"

  # Refresh interval (minimum 30 min = 1800s, maximum 7 days = 604800s)
  refresh_interval             = var.salesforce_refresh_interval
  incremental_refresh_interval = var.salesforce_incremental_refresh_interval

  # Salesforce connection parameters
  params = {
    auth_type     = "OAUTH_TWO_LEGGED"
    client_id     = "${data.google_secret_manager_secret.salesforce_secrets["client_id"].id}/versions/latest"
    client_secret = "${data.google_secret_manager_secret.salesforce_secrets["client_secret"].id}/versions/latest"
    instance_uri  = var.salesforce_instance_url
  }

  # Define entities to sync from Salesforce
  dynamic "entities" {
    for_each = var.salesforce_entities
    content {
      entity_name = entities.value.entity_name
      params      = entities.value.params
    }
  }
  static_ip_enabled = var.salesforce_static_ip_enabled
  auto_run_disabled = var.salesforce_auto_run_disabled
  connector_modes   = var.salesforce_connector_modes
  sync_mode         = var.salesforce_sync_mode

  depends_on = [
    google_secret_manager_secret_iam_member.allow_discovery_engine_read_salesforce
  ]
}
