# =============================================================================
# Gemini Enterprise Module - Core Resources
# =============================================================================
# Creates:
#   - Discovery Engine License Configuration (optional)
#   - Discovery Engine Search Engine
#   - Widget Configuration (optional)
# Connectors are managed in connectors.tf
# =============================================================================

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

  # Discovery Engine always uses default_collection for data store references
  collection_id  = "default_collection"
  data_store_ids = local.effective_data_store_ids

  search_engine_config {
    search_tier    = var.search_tier
    search_add_ons = var.search_add_ons
  }

  depends_on = [
    google_discovery_engine_data_connector.third_party,
    google_discovery_engine_data_connector.workspace,
    google_discovery_engine_license_config.main,
  ]
}

# -----------------------------------------------------------------------------
# Widget Configuration
# Configures the search widget UI: branding, logo, interaction settings
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
