# =============================================================================
# Root Main - Gemini Enterprise Module Invocation
# =============================================================================
# Single module call that passes all configuration. Teams only need to
# modify terraform.tfvars — this file should not require changes.
# =============================================================================

module "gemini_enterprise" {
  source = "./modules/gemini-enterprise"

  # -------------------------------------------------------------------------
  # Core Configuration
  # -------------------------------------------------------------------------
  project_id = var.project_id
  engine_id  = var.search_engine_id
  location   = var.discovery_engine_location

  # API auto-enablement
  enable_discovery_engine_api = var.enable_discovery_engine_api

  # Search engine settings
  engine_display_name = var.search_engine_display_name
  app_type            = var.app_type
  search_tier         = var.search_tier
  search_add_ons      = var.search_add_ons

  # -------------------------------------------------------------------------
  # License Configuration
  # -------------------------------------------------------------------------
  enable_license_config = var.enable_license_config
  license_count         = var.license_count
  free_trial            = var.free_trial
  subscription_tier     = var.subscription_tier
  subscription_term     = var.subscription_term
  start_date            = var.start_date
  end_date              = var.end_date

  # -------------------------------------------------------------------------
  # Data Connectors (all configured via maps — no per-connector variables)
  # -------------------------------------------------------------------------
  third_party_connectors = var.third_party_connectors
  workspace_connectors   = var.workspace_connectors
  cloud_connectors       = var.cloud_connectors
  cloud_data_stores      = var.cloud_data_stores

  # -------------------------------------------------------------------------
  # Engine Features (NotebookLM, People Search, etc.)
  # -------------------------------------------------------------------------
  engine_features = var.engine_features

  # -------------------------------------------------------------------------
  # Widget Configuration
  # -------------------------------------------------------------------------
  enable_widget_config           = var.enable_widget_config
  widget_config_id               = var.widget_config_id
  widget_enable_web_app          = var.widget_enable_web_app
  widget_allow_public_access     = var.widget_allow_public_access
  widget_allowlisted_domains     = var.widget_allowlisted_domains
  widget_interaction_type        = var.widget_interaction_type
  widget_enable_autocomplete     = var.widget_enable_autocomplete
  widget_enable_quality_feedback = var.widget_enable_quality_feedback
  widget_enable_safe_search      = var.widget_enable_safe_search
  widget_logo_url                = var.widget_logo_url
  widget_homepage_shortcuts      = var.widget_homepage_shortcuts
}
