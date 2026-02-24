# -----------------------------------------------------------------------------
# Gemini Enterprise Module
# Creates Discovery Engine License Config and Search Engine for Gemini Enterprise
# -----------------------------------------------------------------------------

locals {
  # Compute license config ID if not provided
  license_config_id = var.license_config_id != null ? var.license_config_id : "${var.project_id}-${var.engine_id}"

  # Compute display name if not provided
  engine_display_name = var.engine_display_name != null ? var.engine_display_name : var.engine_id

  # Jira data store IDs - the connector creates one data store per entity
  # Format: {collection_id}_{entity_name}
  # Note: These are created in default_collection, not the custom collection
  jira_data_store_ids = var.enable_jira_connector ? [
    for entity in var.jira_entities : "${var.collection_id}_${entity.entity_name}"
  ] : []

  confluence_data_store_ids = var.enable_confluence_connector ? [
    for entity in var.confluence_entities : "${var.confluence_collection_id}_${entity.entity_name}"
  ] : []

  mail_data_store_ids     = var.enable_mail_connector ? ["${var.mail_collection_id}_${var.mail_entity.entity_name}"] : []
  calendar_data_store_ids = var.enable_calendar_connector ? ["${var.calendar_collection_id}_${var.calendar_entity.entity_name}"] : []
  drive_data_store_ids    = var.enable_drive_connector ? ["${var.drive_collection_id}_${var.drive_entity.entity_name}"] : []

  salesforce_data_store_ids = var.enable_salesforce_connector ? [
    for entity in var.salesforce_entities : "${var.salesforce_collection_id}_${entity.entity_name}"
  ] : []
}

# -----------------------------------------------------------------------------
# License Configuration
# -----------------------------------------------------------------------------

resource "google_discovery_engine_license_config" "main" {
  count = var.enable_license_config ? 1 : 0

  project           = var.project_id
  location          = var.location
  license_config_id = local.license_config_id
  license_count     = var.license_count
  free_trial        = var.free_trial
  subscription_tier = var.subscription_tier

  start_date {
    year  = var.start_date.year
    month = var.start_date.month
    day   = var.start_date.day
  }

  end_date {
    year  = var.end_date.year
    month = var.end_date.month
    day   = var.end_date.day
  }

  subscription_term = var.subscription_term

}

# -----------------------------------------------------------------------------
# Search Engine (Gemini Enterprise App)
# -----------------------------------------------------------------------------

resource "google_discovery_engine_search_engine" "main" {
  provider = google

  project      = var.project_id
  engine_id    = var.engine_id
  location     = var.location
  display_name = local.engine_display_name
  app_type     = var.app_type

  # IMPORTANT: The search engine must use default_collection because that's where
  # the Jira connector creates its data stores (regardless of collection_id setting)
  collection_id = "default_collection"

  # Use the Jira data store IDs if connector is enabled, otherwise use provided data_store_ids
  # The Jira connector creates data stores named: {collection_id}_{entity_name}
  data_store_ids = (
    var.enable_jira_connector ||
    var.enable_confluence_connector ||
    var.enable_calendar_connector ||
    var.enable_mail_connector ||
    var.enable_drive_connector ||
    var.enable_salesforce_connector
    ) ? concat(
    local.jira_data_store_ids,
    local.confluence_data_store_ids,
    local.calendar_data_store_ids,
    local.mail_data_store_ids,
    local.drive_data_store_ids,
    local.salesforce_data_store_ids
  ) : var.data_store_ids


  search_engine_config {
    search_tier    = var.search_tier
    search_add_ons = var.search_add_ons
  }

  depends_on = [
    google_discovery_engine_data_connector.jira,
    google_discovery_engine_data_connector.confluence,
    google_discovery_engine_data_connector.salesforce,
    google_discovery_engine_data_connector.mail,
    google_discovery_engine_data_connector.calendar,
    google_discovery_engine_data_connector.drive,
    google_discovery_engine_license_config.main,
  ]
}

# -----------------------------------------------------------------------------
# Widget Configuration
# Configures the search widget UI including branding, logo, and interaction settings
# -----------------------------------------------------------------------------

resource "google_discovery_engine_widget_config" "main" {
  count    = var.enable_widget_config ? 1 : 0
  provider = google

  project          = var.project_id
  location         = var.location
  engine_id        = google_discovery_engine_search_engine.main.engine_id
  collection_id    = "default_collection"
  widget_config_id = var.widget_config_id

  access_settings {
    enable_web_app      = var.widget_enable_web_app
    allow_public_access = var.widget_allow_public_access
    allowlisted_domains = var.widget_allowlisted_domains
  }

  ui_settings {
    interaction_type        = var.widget_interaction_type
    enable_autocomplete     = var.widget_enable_autocomplete
    enable_quality_feedback = var.widget_enable_quality_feedback
    enable_safe_search      = var.widget_enable_safe_search
  }

  dynamic "ui_branding" {
    for_each = var.widget_logo_url != null ? [1] : []
    content {
      logo {
        url = var.widget_logo_url
      }
    }
  }

  dynamic "homepage_setting" {
    for_each = length(var.widget_homepage_shortcuts) > 0 ? [1] : []
    content {
      dynamic "shortcuts" {
        for_each = var.widget_homepage_shortcuts
        content {
          title           = shortcuts.value.title
          destination_uri = shortcuts.value.destination_uri
        }
      }
    }
  }

  depends_on = [google_discovery_engine_search_engine.main]
}
