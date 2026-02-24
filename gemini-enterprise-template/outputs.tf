# =============================================================================
# Root Outputs
# =============================================================================

# -----------------------------------------------------------------------------
# Search Engine
# -----------------------------------------------------------------------------

output "search_engine_id" {
  description = "The ID of the Discovery Engine search engine"
  value       = module.gemini_enterprise.engine_id
}

output "search_engine_name" {
  description = "The full resource name of the search engine"
  value       = module.gemini_enterprise.engine_name
}

output "search_engine_display_name" {
  description = "The display name of the search engine"
  value       = module.gemini_enterprise.engine_display_name
}

output "engine_full_id" {
  description = "The full resource ID of the search engine"
  value       = module.gemini_enterprise.engine_full_id
}

# -----------------------------------------------------------------------------
# License
# -----------------------------------------------------------------------------

output "license_config_id" {
  description = "The ID of the license configuration"
  value       = module.gemini_enterprise.license_config_id
}

output "license_config_name" {
  description = "The full resource name of the license configuration"
  value       = module.gemini_enterprise.license_config_name
}

# -----------------------------------------------------------------------------
# Console URLs
# -----------------------------------------------------------------------------

output "gemini_enterprise_console_url" {
  description = "URL to the Gemini Enterprise app console"
  value       = module.gemini_enterprise.console_url
}

output "discovery_engine_console_url" {
  description = "URL to the Discovery Engine console"
  value       = "https://console.cloud.google.com/gen-app-builder/engines?project=${var.project_id}"
}

output "vertex_ai_search_url" {
  description = "URL to the Vertex AI Search webapp"
  value       = module.gemini_enterprise.vertex_ai_search_url
}

# -----------------------------------------------------------------------------
# Connectors
# -----------------------------------------------------------------------------

output "third_party_connector_names" {
  description = "Map of third-party connector resource names"
  value       = module.gemini_enterprise.third_party_connector_names
}

output "third_party_connector_states" {
  description = "Map of third-party connector states"
  value       = module.gemini_enterprise.third_party_connector_states
}

output "workspace_connector_names" {
  description = "Map of workspace connector resource names"
  value       = module.gemini_enterprise.workspace_connector_names
}

output "workspace_connector_states" {
  description = "Map of workspace connector states"
  value       = module.gemini_enterprise.workspace_connector_states
}

# -----------------------------------------------------------------------------
# Widget
# -----------------------------------------------------------------------------

output "widget_config_id" {
  description = "The ID of the widget configuration"
  value       = module.gemini_enterprise.widget_config_id
}

# -----------------------------------------------------------------------------
# Data Stores
# -----------------------------------------------------------------------------

output "linked_data_store_ids" {
  description = "All data store IDs linked to the search engine"
  value       = module.gemini_enterprise.data_store_ids
}
