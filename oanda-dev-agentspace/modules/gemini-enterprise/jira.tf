# -----------------------------------------------------------------------------
# Jira Cloud Data Connector
# Reads existing secrets from Secret Manager for secure credential access
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# Discovery Engine Service Agent Identity
# -----------------------------------------------------------------------------
resource "google_project_service_identity" "discovery_engine_sa" {
  count    = var.enable_jira_connector || var.enable_salesforce_connector ? 1 : 0
  provider = google-beta
  project  = var.project_id
  service  = "discoveryengine.googleapis.com"
}
# -----------------------------------------------------------------------------
# Read Existing Secrets from Secret Manager
# -----------------------------------------------------------------------------
data "google_secret_manager_secret" "jira_secrets" {
  for_each = var.enable_jira_connector ? {
    client_id     = "ONIX_JIRA_INTEGRATION_CLIENTID"
    client_secret = "ONIX_JIRA_INTEGRATION_SECRET"
    refresh_token = "ONIX_JIRA_INTEGRATION_REFRESH_TOKEN"
  } : {}
  provider  = google
  project   = var.project_id
  secret_id = each.value
}
# -----------------------------------------------------------------------------
# IAM Permissions for Discovery Engine to Read Secrets
# -----------------------------------------------------------------------------
resource "google_secret_manager_secret_iam_member" "allow_discovery_engine_read_jira" {
  for_each  = data.google_secret_manager_secret.jira_secrets
  provider  = google
  project   = var.project_id
  secret_id = each.value.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_project_service_identity.discovery_engine_sa[0].email}"
}
# -----------------------------------------------------------------------------
# Jira Data Connector
# -----------------------------------------------------------------------------
resource "google_discovery_engine_data_connector" "jira" {
  count                   = var.enable_jira_connector ? 1 : 0
  provider                = google
  project                 = var.project_id
  location                = var.location
  collection_id           = var.collection_id
  collection_display_name = var.collection_display_name
  data_source             = "jira"
  params = {
    instance_uri  = var.jira_instance_uri
    instance_id   = var.jira_instance_id
    client_id     = "${data.google_secret_manager_secret.jira_secrets["client_id"].id}/versions/latest"
    client_secret = "${data.google_secret_manager_secret.jira_secrets["client_secret"].id}/versions/latest"
    refresh_token = "${data.google_secret_manager_secret.jira_secrets["refresh_token"].id}/versions/latest"
  }
  refresh_interval             = var.jira_refresh_interval
  incremental_refresh_interval = var.jira_incremental_refresh_interval
  dynamic "entities" {
    for_each = var.jira_entities
    content {
      entity_name = entities.value.entity_name
      params      = entities.value.params
    }
  }
  static_ip_enabled = var.jira_static_ip_enabled
  connector_modes   = var.jira_connector_modes
  sync_mode         = var.jira_sync_mode
  lifecycle {
    ignore_changes = all
  }
  depends_on = [
    # google_discovery_engine_license_config.main,
    google_secret_manager_secret_iam_member.allow_discovery_engine_read_jira
  ]
}
