# =============================================================================
# Gemini Enterprise Module - Variables
# =============================================================================
# This module uses structured maps for connector configuration instead of
# individual variables per connector. This eliminates code duplication and
# allows teams to configure any connector via a single config file.
# =============================================================================

# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "The GCP project ID where Gemini Enterprise resources will be created"
  type        = string
}

variable "engine_id" {
  description = "Unique identifier for the Gemini Enterprise search engine"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.engine_id)) && length(var.engine_id) <= 63
    error_message = "Engine ID must start with a lowercase letter, contain only lowercase letters, numbers, and hyphens, end with a letter or number, and be at most 63 characters."
  }
}

# -----------------------------------------------------------------------------
# Location Configuration
# -----------------------------------------------------------------------------

variable "location" {
  description = "Location for Discovery Engine resources"
  type        = string
  default     = "global"

  validation {
    condition     = contains(["global", "us", "eu"], var.location)
    error_message = "Location must be one of: global, us, eu."
  }
}

# -----------------------------------------------------------------------------
# License Configuration
# -----------------------------------------------------------------------------

variable "enable_license_config" {
  description = "Whether to create a license configuration for Gemini Enterprise"
  type        = bool
  default     = false
}

variable "license_config_id" {
  description = "Unique identifier for the license configuration. Defaults to project_id-engine_id if not set"
  type        = string
  default     = null
}

variable "license_count" {
  description = "Number of Gemini Enterprise licenses to provision"
  type        = number
  default     = 25

  validation {
    condition     = var.license_count > 0
    error_message = "License count must be greater than 0."
  }
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

  validation {
    condition     = contains(["SUBSCRIPTION_TIER_UNSPECIFIED", "SUBSCRIPTION_TIER_STANDARD", "SUBSCRIPTION_TIER_ENTERPRISE"], var.subscription_tier)
    error_message = "Subscription tier must be one of: SUBSCRIPTION_TIER_UNSPECIFIED, SUBSCRIPTION_TIER_STANDARD, SUBSCRIPTION_TIER_ENTERPRISE."
  }
}

variable "subscription_term" {
  description = "Subscription term length"
  type        = string
  default     = "SUBSCRIPTION_TERM_ONE_MONTH"

  validation {
    condition     = contains(["SUBSCRIPTION_TERM_UNSPECIFIED", "SUBSCRIPTION_TERM_ONE_MONTH", "SUBSCRIPTION_TERM_ONE_YEAR", "SUBSCRIPTION_TERM_THREE_YEARS"], var.subscription_term)
    error_message = "Subscription term must be one of: SUBSCRIPTION_TERM_UNSPECIFIED, SUBSCRIPTION_TERM_ONE_MONTH, SUBSCRIPTION_TERM_ONE_YEAR, SUBSCRIPTION_TERM_THREE_YEARS."
  }
}

variable "start_date" {
  description = "Start date for the license subscription"
  type = object({
    year  = number
    month = number
    day   = number
  })
  default = { year = 2025, month = 1, day = 1 }

  validation {
    condition     = var.start_date.month >= 1 && var.start_date.month <= 12 && var.start_date.day >= 1 && var.start_date.day <= 31
    error_message = "Start date must have valid month (1-12) and day (1-31)."
  }
}

variable "end_date" {
  description = "End date for the license subscription"
  type = object({
    year  = number
    month = number
    day   = number
  })
  default = { year = 2025, month = 12, day = 31 }

  validation {
    condition     = var.end_date.month >= 1 && var.end_date.month <= 12 && var.end_date.day >= 1 && var.end_date.day <= 31
    error_message = "End date must have valid month (1-12) and day (1-31)."
  }
}

# -----------------------------------------------------------------------------
# Search Engine Configuration
# -----------------------------------------------------------------------------

variable "engine_display_name" {
  description = "Display name for the search engine. Defaults to engine_id if not set"
  type        = string
  default     = null
}

variable "data_store_ids" {
  description = "Explicit data store IDs (only used when no connectors are enabled)"
  type        = list(string)
  default     = []
}

variable "app_type" {
  description = "Application type for the search engine"
  type        = string
  default     = "APP_TYPE_INTRANET"

  validation {
    condition     = contains(["APP_TYPE_UNSPECIFIED", "APP_TYPE_INTRANET", "APP_TYPE_INTERNET"], var.app_type)
    error_message = "App type must be one of: APP_TYPE_UNSPECIFIED, APP_TYPE_INTRANET, APP_TYPE_INTERNET."
  }
}

variable "search_tier" {
  description = "Search tier for the engine"
  type        = string
  default     = "SEARCH_TIER_ENTERPRISE"

  validation {
    condition     = contains(["SEARCH_TIER_STANDARD", "SEARCH_TIER_ENTERPRISE"], var.search_tier)
    error_message = "Search tier must be one of: SEARCH_TIER_STANDARD, SEARCH_TIER_ENTERPRISE."
  }
}

variable "search_add_ons" {
  description = "List of search add-ons to enable"
  type        = list(string)
  default     = ["SEARCH_ADD_ON_LLM"]

  validation {
    condition     = alltrue([for addon in var.search_add_ons : contains(["SEARCH_ADD_ON_LLM"], addon)])
    error_message = "Search add-ons must be one of: SEARCH_ADD_ON_LLM."
  }
}

# =============================================================================
# CONNECTOR CONFIGURATION
# =============================================================================
# Instead of dozens of individual variables per connector type, connectors are
# configured via two structured maps. This design:
#   - Eliminates code duplication (6 connector files → 1 unified resource)
#   - Allows adding new connector instances without any code changes
#   - Keeps all configuration in terraform.tfvars
# =============================================================================

# -----------------------------------------------------------------------------
# Third-Party Connectors (OAuth-based)
# Supports: Jira, Confluence, Salesforce, and any future OAuth connector
# -----------------------------------------------------------------------------

variable "third_party_connectors" {
  description = <<-EOT
    Map of third-party data connectors requiring OAuth credentials from Secret Manager.
    Each key is a unique connector name (e.g., "jira", "confluence", "salesforce").

    Required fields:
      - data_source:              Connector type ("jira", "confluence", "salesforce")
      - collection_id:            Unique collection identifier for this connector
      - collection_display_name:  Human-readable collection name
      - params:                   Non-secret connection parameters (e.g., instance_uri, instance_id, auth_type)
      - secrets:                  Map of Secret Manager secret IDs for OAuth credentials
      - entities:                 List of entities to sync

    Optional fields (with defaults):
      - enabled:                       Whether this connector is active (default: true)
      - refresh_interval:              Full sync interval (default: "86400s")
      - incremental_refresh_interval:  Incremental sync interval (default: null)
      - static_ip_enabled:             Use static IP (default: false)
      - connector_modes:               ["DATA_INGESTION"] and/or ["FEDERATED"] (default: ["FEDERATED"])
      - sync_mode:                     "PERIODIC" or "MANUAL" (default: "PERIODIC")
      - auto_run_disabled:             Disable automatic sync (default: false)
  EOT

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

# -----------------------------------------------------------------------------
# Google Workspace Connectors (Native, no OAuth secrets needed)
# Supports: Gmail, Calendar, Drive
# -----------------------------------------------------------------------------

variable "workspace_connectors" {
  description = <<-EOT
    Map of Google Workspace data connectors (no OAuth secrets required).
    Each key is a unique connector name (e.g., "gmail", "calendar", "drive").

    Required fields:
      - data_source:              Connector type ("google_mail", "google_calendar", "google_drive")
      - collection_id:            Unique collection identifier for this connector
      - collection_display_name:  Human-readable collection name
      - entity:                   Single entity configuration with entity_name matching data_source

    Optional fields (with defaults):
      - enabled:            Whether this connector is active (default: true)
      - refresh_interval:   Sync interval (default: "3600s")
      - static_ip_enabled:  Use static IP (default: false)
      - connector_modes:    ["DATA_INGESTION"] and/or ["FEDERATED"] (default: ["FEDERATED"])
      - auto_run_disabled:  Disable automatic sync (default: false)
  EOT

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

# -----------------------------------------------------------------------------
# Widget Configuration
# -----------------------------------------------------------------------------

variable "enable_widget_config" {
  description = "Whether to create a widget configuration for the search engine"
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
  description = "Type of search interaction"
  type        = string
  default     = "SEARCH_WITH_ANSWER"

  validation {
    condition     = contains(["SEARCH_ONLY", "SEARCH_WITH_ANSWER", "SEARCH_WITH_FOLLOW_UPS"], var.widget_interaction_type)
    error_message = "Interaction type must be one of: SEARCH_ONLY, SEARCH_WITH_ANSWER, SEARCH_WITH_FOLLOW_UPS."
  }
}

variable "widget_enable_autocomplete" {
  description = "Whether to enable autocomplete in the search widget"
  type        = bool
  default     = true
}

variable "widget_enable_quality_feedback" {
  description = "Whether to enable quality feedback in the search widget"
  type        = bool
  default     = true
}

variable "widget_enable_safe_search" {
  description = "Whether to enable safe search in the widget"
  type        = bool
  default     = true
}

variable "widget_logo_url" {
  description = "URL of the logo image to display in the widget (must be publicly accessible)"
  type        = string
  default     = null
}

variable "widget_homepage_shortcuts" {
  description = "List of shortcuts to display on the widget homepage"
  type = list(object({
    title           = string
    destination_uri = string
  }))
  default = []
}
