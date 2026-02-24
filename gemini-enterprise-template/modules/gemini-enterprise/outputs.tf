# =============================================================================
# Gemini Enterprise Module - Outputs
# =============================================================================

# -----------------------------------------------------------------------------
# License Configuration
# -----------------------------------------------------------------------------

output "license_config_id" {
  description = "The ID of the created license configuration"
  value       = var.enable_license_config ? google_discovery_engine_license_config.main[0].license_config_id : null
}

output "license_config_name" {
  description = "The full resource name of the license configuration"
  value       = var.enable_license_config ? google_discovery_engine_license_config.main[0].name : null
}

# -----------------------------------------------------------------------------
# Search Engine
# -----------------------------------------------------------------------------

output "engine_id" {
  description = "The ID of the created search engine"
  value       = google_discovery_engine_search_engine.main.engine_id
}

output "engine_name" {
  description = "The full resource name of the search engine"
  value       = google_discovery_engine_search_engine.main.name
}

output "engine_display_name" {
  description = "The display name of the search engine"
  value       = google_discovery_engine_search_engine.main.display_name
}

output "engine_full_id" {
  description = "The full resource ID of the search engine"
  value       = google_discovery_engine_search_engine.main.id
}

output "project_id" {
  description = "The project ID where resources were created"
  value       = var.project_id
}

output "console_url" {
  description = "URL to the Gemini Enterprise console"
  value       = "https://console.cloud.google.com/gen-app-builder/engines/${google_discovery_engine_search_engine.main.engine_id}/overview?project=${var.project_id}"
}

output "vertex_ai_search_url" {
  description = "URL to the Vertex AI Search webapp (CID must be obtained from Cloud Console)"
  value       = "https://vertexaisearch.cloud.google.com/home/cid/<CID_FROM_CONSOLE>?hl=en_US"
}

# -----------------------------------------------------------------------------
# Third-Party Connector Outputs
# -----------------------------------------------------------------------------

output "third_party_connector_names" {
  description = "Map of third-party connector names (key → resource name)"
  value = {
    for k, v in google_discovery_engine_data_connector.third_party : k => v.name
  }
}

output "third_party_connector_states" {
  description = "Map of third-party connector states (key → state)"
  value = {
    for k, v in google_discovery_engine_data_connector.third_party : k => v.state
  }
}

# -----------------------------------------------------------------------------
# Workspace Connector Outputs
# -----------------------------------------------------------------------------

output "workspace_connector_names" {
  description = "Map of workspace connector names (key → resource name)"
  value = {
    for k, v in google_discovery_engine_data_connector.workspace : k => v.name
  }
}

output "workspace_connector_states" {
  description = "Map of workspace connector states (key → state)"
  value = {
    for k, v in google_discovery_engine_data_connector.workspace : k => v.state
  }
}

# -----------------------------------------------------------------------------
# Widget Configuration
# -----------------------------------------------------------------------------

output "widget_config_id" {
  description = "The ID of the widget configuration"
  value       = var.enable_widget_config ? google_discovery_engine_widget_config.main[0].widget_config_id : null
}

output "widget_config_name" {
  description = "The full resource name of the widget configuration"
  value       = var.enable_widget_config ? google_discovery_engine_widget_config.main[0].name : null
}

# -----------------------------------------------------------------------------
# Data Store IDs
# -----------------------------------------------------------------------------

output "data_store_ids" {
  description = "List of all data store IDs linked to the search engine"
  value       = local.effective_data_store_ids
}
