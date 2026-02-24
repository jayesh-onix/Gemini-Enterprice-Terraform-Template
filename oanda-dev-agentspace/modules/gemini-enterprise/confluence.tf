# -----------------------------------------------------------------------------
# Confluence Cloud Data Connector
# -----------------------------------------------------------------------------

# Read Existing Secrets from Secret Manager
data "google_secret_manager_secret" "confluence_secrets" {
  for_each = var.enable_confluence_connector ? {
    client_id     = "ONIX_CONFLUENCE_INTEGRATION_CLIENTID"
    client_secret = "ONIX_CONFLUENCE_INTEGRATION_SECRET"
    refresh_token = "ONIX_CONFLUENCE_INTEGRATION_REFRESH_TOKEN"
  } : {}
  provider  = google
  project   = var.project_id
  secret_id = each.value
}

# IAM Permissions for Discovery Engine Service Agent to Read Confluence Secrets
resource "google_secret_manager_secret_iam_member" "allow_discovery_engine_read_confluence" {
  for_each  = data.google_secret_manager_secret.confluence_secrets
  provider  = google
  project   = var.project_id
  secret_id = each.value.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_project_service_identity.discovery_engine_sa[0].email}"
}

# Confluence Data Connector resource
resource "google_discovery_engine_data_connector" "confluence" {
  count                   = var.enable_confluence_connector ? 1 : 0
  provider                = google
  project                 = var.project_id
  location                = var.location
  collection_id           = var.confluence_collection_id
  collection_display_name = var.confluence_collection_display_name
  data_source             = "confluence"
  params = {
    instance_uri  = var.confluence_instance_uri
    instance_id   = var.confluence_instance_id
    client_id     = "${data.google_secret_manager_secret.confluence_secrets["client_id"].id}/versions/latest"
    client_secret = "${data.google_secret_manager_secret.confluence_secrets["client_secret"].id}/versions/latest"
    refresh_token = "${data.google_secret_manager_secret.confluence_secrets["refresh_token"].id}/versions/latest"
  }
  refresh_interval             = var.confluence_refresh_interval
  incremental_refresh_interval = var.confluence_incremental_refresh_interval
  dynamic "entities" {
    for_each = var.confluence_entities
    content {
      entity_name = entities.value.entity_name
      params      = entities.value.params
    }
  }
  static_ip_enabled = var.confluence_static_ip_enabled
  connector_modes   = var.confluence_connector_modes
  sync_mode         = var.confluence_sync_mode

  lifecycle {
    ignore_changes = all
  }

  depends_on = [
    google_secret_manager_secret_iam_member.allow_discovery_engine_read_confluence
  ]
}
