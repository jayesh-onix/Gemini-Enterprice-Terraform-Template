# =============================================================================
# Root Variables
# =============================================================================
# These are the only variables teams need to set. All connector configuration
# is handled through the structured maps below — no code changes needed.
# =============================================================================

# -----------------------------------------------------------------------------
# Required
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "The GCP project ID where resources will be created"
  type        = string
}

# -----------------------------------------------------------------------------
# Gemini Enterprise Configuration
# -----------------------------------------------------------------------------

variable "discovery_engine_location" {
  description = "Location for Discovery Engine resources (global, us, eu)"
  type        = string
  default     = "global"
}

variable "search_engine_id" {
  description = "Unique identifier for the Gemini Enterprise search engine"
  type        = string
  default     = "gemini-enterprise-app"
}

variable "search_engine_display_name" {
  description = "Display name for the Gemini Enterprise search engine"
  type        = string
  default     = "Gemini Enterprise Search"
}

variable "app_type" {
  description = "Application type (APP_TYPE_INTRANET, APP_TYPE_INTERNET)"
  type        = string
  default     = "APP_TYPE_INTRANET"
}

variable "search_tier" {
  description = "Search tier (SEARCH_TIER_STANDARD, SEARCH_TIER_ENTERPRISE)"
  type        = string
  default     = "SEARCH_TIER_ENTERPRISE"
}

variable "search_add_ons" {
  description = "List of search add-ons to enable"
  type        = list(string)
  default     = ["SEARCH_ADD_ON_LLM"]
}

# -----------------------------------------------------------------------------
# License Configuration
# -----------------------------------------------------------------------------

variable "enable_license_config" {
  description = "Whether to create a license configuration"
  type        = bool
  default     = false
}

variable "license_count" {
  description = "Number of Gemini Enterprise licenses"
  type        = number
  default     = 25
}

variable "free_trial" {
  description = "Whether this is a free trial license"
  type        = bool
  default     = true
}

variable "subscription_tier" {
  description = "Subscription tier for Gemini Enterprise"
  type        = string
  default     = "SUBSCRIPTION_TIER_ENTERPRISE"
}

variable "subscription_term" {
  description = "Subscription term length"
  type        = string
  default     = "SUBSCRIPTION_TERM_ONE_MONTH"
}

variable "start_date" {
  description = "License start date"
  type = object({
    year  = number
    month = number
    day   = number
  })
  default = { year = 2025, month = 1, day = 1 }
}

variable "end_date" {
  description = "License end date"
  type = object({
    year  = number
    month = number
    day   = number
  })
  default = { year = 2025, month = 12, day = 31 }
}

# -----------------------------------------------------------------------------
# API Configuration
# -----------------------------------------------------------------------------

variable "enable_discovery_engine_api" {
  description = "Whether to auto-enable the Discovery Engine API. Set to false if API is already managed externally."
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Data Connectors
# See terraform.tfvars.example for full configuration examples
# -----------------------------------------------------------------------------

variable "third_party_connectors" {
  description = "Map of third-party OAuth connectors (Jira, Confluence, Salesforce, etc.)"
  type = map(object({
    enabled                      = optional(bool, true)
    data_source                  = string
    collection_id                = string
    collection_display_name      = string
    params                       = map(string)
    secrets                      = map(string)
    refresh_interval             = optional(string, "86400s")
    incremental_refresh_interval = optional(string, null)
    entities = list(object({
      entity_name = string
      params      = optional(string, null)
    }))
    static_ip_enabled = optional(bool, false)
    connector_modes   = optional(list(string), ["FEDERATED"])
    sync_mode         = optional(string, "PERIODIC")
    auto_run_disabled = optional(bool, false)
  }))
  default = {}
}

variable "workspace_connectors" {
  description = "Map of Google Workspace connectors (Gmail, Calendar, Drive, Sites, Groups, People)"
  type = map(object({
    enabled                 = optional(bool, true)
    data_source             = string
    collection_id           = string
    collection_display_name = string
    refresh_interval        = optional(string, "3600s")
    entity = object({
      entity_name = string
      params      = optional(string, null)
    })
    static_ip_enabled = optional(bool, false)
    connector_modes   = optional(list(string), ["FEDERATED"])
    auto_run_disabled = optional(bool, false)
  }))
  default = {}
}

variable "cloud_connectors" {
  description = "Map of GCP cloud source connectors (BigQuery, Cloud Storage, Cloud SQL, Spanner, AlloyDB)"
  type = map(object({
    enabled                      = optional(bool, true)
    data_source                  = string
    collection_id                = string
    collection_display_name      = string
    params                       = optional(map(string), {})
    refresh_interval             = optional(string, "86400s")
    incremental_refresh_interval = optional(string, null)
    entities = list(object({
      entity_name = string
      params      = optional(string, null)
    }))
    static_ip_enabled = optional(bool, false)
    connector_modes   = optional(list(string), ["DATA_INGESTION"])
    sync_mode         = optional(string, "PERIODIC")
    auto_run_disabled = optional(bool, false)
  }))
  default = {}
}

variable "cloud_data_stores" {
  description = "Map of standalone data stores (Announcements, custom data stores)"
  type = map(object({
    enabled                      = optional(bool, true)
    data_store_id                = string
    display_name                 = string
    industry_vertical            = optional(string, "GENERIC")
    content_config               = optional(string, "CONTENT_REQUIRED")
    solution_types               = optional(list(string), ["SOLUTION_TYPE_SEARCH"])
    create_advanced_site_search  = optional(bool, false)
    skip_default_schema_creation = optional(bool, false)
  }))
  default = {}
}

variable "engine_features" {
  description = "Map of engine feature flags (e.g., notebook-lm, people-search-org-chart)"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Widget Configuration
# -----------------------------------------------------------------------------

variable "enable_widget_config" {
  description = "Whether to create a widget configuration"
  type        = bool
  default     = true
}

variable "widget_config_id" {
  description = "Unique identifier for the widget configuration"
  type        = string
  default     = "default_search_widget_config"
}

variable "widget_enable_web_app" {
  description = "Whether to enable the web app for the widget"
  type        = bool
  default     = true
}

variable "widget_allow_public_access" {
  description = "Whether to allow public access to the widget"
  type        = bool
  default     = false
}

variable "widget_allowlisted_domains" {
  description = "List of domains allowed to embed the widget"
  type        = list(string)
  default     = []
}

variable "widget_interaction_type" {
  description = "Type of search interaction (SEARCH_ONLY, SEARCH_WITH_ANSWER, SEARCH_WITH_FOLLOW_UPS)"
  type        = string
  default     = "SEARCH_WITH_ANSWER"
}

variable "widget_enable_autocomplete" {
  description = "Whether to enable autocomplete"
  type        = bool
  default     = true
}

variable "widget_enable_quality_feedback" {
  description = "Whether to enable quality feedback"
  type        = bool
  default     = true
}

variable "widget_enable_safe_search" {
  description = "Whether to enable safe search"
  type        = bool
  default     = true
}

variable "widget_logo_url" {
  description = "URL of the custom logo for the widget (publicly accessible)"
  type        = string
  default     = null
}

variable "widget_homepage_shortcuts" {
  description = "List of shortcuts for the widget homepage"
  type = list(object({
    title           = string
    destination_uri = string
  }))
  default = []
}
