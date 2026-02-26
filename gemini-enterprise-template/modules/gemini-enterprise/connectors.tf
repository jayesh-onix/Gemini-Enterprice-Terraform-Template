# =============================================================================
# Unified Data Connectors
# =============================================================================
# This file replaces 6 separate connector files (jira.tf, confluence.tf,
# salesforce.tf, mail.tf, calendar.tf, drive.tf) with a single, generic
# implementation that uses for_each to create any number of connectors
# from configuration maps.
# =============================================================================

# -----------------------------------------------------------------------------
# GCP API Enablement
# Auto-enables required APIs so users don't need to do it manually
# -----------------------------------------------------------------------------

resource "google_project_service" "discoveryengine" {
  count   = var.enable_discovery_engine_api ? 1 : 0
  project = var.project_id
  service = "discoveryengine.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "secretmanager" {
  count   = local.needs_service_identity ? 1 : 0
  project = var.project_id
  service = "secretmanager.googleapis.com"

  disable_on_destroy = false
}

# -----------------------------------------------------------------------------
# Discovery Engine Service Agent Identity
# Required for granting Secret Manager access to third-party connectors
# -----------------------------------------------------------------------------

resource "google_project_service_identity" "discovery_engine_sa" {
  count    = local.needs_service_identity ? 1 : 0
  provider = google-beta
  project  = var.project_id
  service  = "discoveryengine.googleapis.com"

  depends_on = [google_project_service.discoveryengine]
}

# -----------------------------------------------------------------------------
# Secret Manager - Lookup & IAM
# Resolves Secret Manager secrets and grants Discovery Engine SA read access
# -----------------------------------------------------------------------------

data "google_secret_manager_secret" "connector_secrets" {
  for_each  = local.connector_secrets_flat
  provider  = google
  project   = var.project_id
  secret_id = each.value.secret_id

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_iam_member" "discovery_engine_secret_access" {
  for_each  = local.connector_secrets_flat
  provider  = google
  project   = var.project_id
  secret_id = data.google_secret_manager_secret.connector_secrets[each.key].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_project_service_identity.discovery_engine_sa[0].email}"
}

# -----------------------------------------------------------------------------
# Third-Party Data Connectors (OAuth-based)
# Creates connectors for Jira, Confluence, Salesforce, etc.
# Secrets are resolved from Secret Manager and merged into params automatically
# -----------------------------------------------------------------------------

resource "google_discovery_engine_data_connector" "third_party" {
  for_each = local.enabled_third_party_connectors

  provider                = google
  project                 = var.project_id
  location                = var.location
  collection_id           = each.value.collection_id
  collection_display_name = each.value.collection_display_name
  data_source             = each.value.data_source

  # Merge user-provided params with resolved secret references
  params = merge(
    each.value.params,
    {
      for secret_key, secret_id in each.value.secrets :
      secret_key => "${data.google_secret_manager_secret.connector_secrets["${each.key}/${secret_key}"].id}/versions/latest"
    }
  )

  refresh_interval             = each.value.refresh_interval
  incremental_refresh_interval = each.value.incremental_refresh_interval

  dynamic "entities" {
    for_each = each.value.entities
    content {
      entity_name = entities.value.entity_name
      params      = entities.value.params
    }
  }

  static_ip_enabled = each.value.static_ip_enabled
  connector_modes   = each.value.connector_modes
  sync_mode         = each.value.sync_mode
  auto_run_disabled = each.value.auto_run_disabled

  lifecycle {
    ignore_changes = all
  }

  depends_on = [
    google_project_service.discoveryengine,
    google_secret_manager_secret_iam_member.discovery_engine_secret_access,
    google_discovery_engine_license_config.main
  ]
}

# -----------------------------------------------------------------------------
# Google Workspace Data Connectors (Native)
# Creates connectors for Gmail, Calendar, Drive, Sites, Groups, People
# No OAuth secrets required - uses Google Workspace / Cloud Identity
# -----------------------------------------------------------------------------

resource "google_discovery_engine_data_connector" "workspace" {
  for_each = local.enabled_workspace_connectors

  provider                = google
  project                 = var.project_id
  location                = var.location
  collection_id           = each.value.collection_id
  collection_display_name = each.value.collection_display_name
  data_source             = each.value.data_source

  refresh_interval = each.value.refresh_interval
  json_params      = jsonencode({})

  entities {
    entity_name = each.value.entity.entity_name
    params      = each.value.entity.params
  }

  connector_modes   = each.value.connector_modes
  static_ip_enabled = each.value.static_ip_enabled
  auto_run_disabled = each.value.auto_run_disabled

  depends_on = [
    google_project_service.discoveryengine,
    google_discovery_engine_license_config.main
  ]
}

# -----------------------------------------------------------------------------
# GCP Cloud Source Data Connectors
# Creates connectors for BigQuery, Cloud Storage, Cloud SQL, Spanner, AlloyDB
# No OAuth secrets required — uses project service account
# -----------------------------------------------------------------------------

resource "google_discovery_engine_data_connector" "cloud" {
  for_each = local.enabled_cloud_connectors

  provider                = google
  project                 = var.project_id
  location                = var.location
  collection_id           = each.value.collection_id
  collection_display_name = each.value.collection_display_name
  data_source             = each.value.data_source

  params                       = each.value.params
  refresh_interval             = each.value.refresh_interval
  incremental_refresh_interval = each.value.incremental_refresh_interval

  dynamic "entities" {
    for_each = each.value.entities
    content {
      entity_name = entities.value.entity_name
      params      = entities.value.params
    }
  }

  static_ip_enabled = each.value.static_ip_enabled
  connector_modes   = each.value.connector_modes
  sync_mode         = each.value.sync_mode
  auto_run_disabled = each.value.auto_run_disabled

  lifecycle {
    ignore_changes = all
  }

  depends_on = [
    google_project_service.discoveryengine,
    google_discovery_engine_license_config.main
  ]
}
