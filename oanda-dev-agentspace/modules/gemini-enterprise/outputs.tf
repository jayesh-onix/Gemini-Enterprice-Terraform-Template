# -----------------------------------------------------------------------------
# License Configuration Outputs
# -----------------------------------------------------------------------------

output "license_config_id" {
  description = "The ID of the created license configuration"
  value       = var.enable_license_config ? google_discovery_engine_license_config.main[0].license_config_id : null
}

output "license_config_name" {
  description = "The full resource name of the license configuration"
  value       = var.enable_license_config ? google_discovery_engine_license_config.main[0].name : null
}

output "license_count" {
  description = "The number of licenses provisioned"
  value       = var.enable_license_config ? google_discovery_engine_license_config.main[0].license_count : null
}

output "subscription_tier" {
  description = "The subscription tier of the license"
  value       = var.enable_license_config ? google_discovery_engine_license_config.main[0].subscription_tier : null
}

# -----------------------------------------------------------------------------
# Search Engine Outputs
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

output "engine_location" {
  description = "The location of the search engine"
  value       = google_discovery_engine_search_engine.main.location
}

output "engine_collection_id" {
  description = "The collection ID of the search engine"
  value       = google_discovery_engine_search_engine.main.collection_id
}

output "app_type" {
  description = "The application type of the search engine"
  value       = google_discovery_engine_search_engine.main.app_type
}

output "search_tier" {
  description = "The search tier configured for the engine"
  value       = var.search_tier
}

output "search_add_ons" {
  description = "The search add-ons enabled for the engine"
  value       = var.search_add_ons
}

# -----------------------------------------------------------------------------
# Convenience Outputs
# -----------------------------------------------------------------------------

output "project_id" {
  description = "The project ID where resources were created"
  value       = var.project_id
}

output "console_url" {
  description = "URL to the Gemini Enterprise console"
  value       = "https://console.cloud.google.com/gen-app-builder/engines/${google_discovery_engine_search_engine.main.engine_id}/overview?project=${var.project_id}"
}

output "vertex_ai_search_url" {
  description = "URL to the Vertex AI Search webapp for end users. Note: The cid value must be obtained from the Cloud Console after deployment."
  value       = "https://vertexaisearch.cloud.google.com/home/cid/<CID_FROM_CONSOLE>?hl=en_US"
}

output "engine_full_id" {
  description = "The full resource ID of the search engine (may contain the cid for the Vertex AI Search URL)"
  value       = google_discovery_engine_search_engine.main.id
}

# -----------------------------------------------------------------------------
# Jira Connector Outputs
# -----------------------------------------------------------------------------

output "jira_connector_name" {
  description = "The full resource name of the Jira data connector"
  value       = var.enable_jira_connector ? google_discovery_engine_data_connector.jira[0].name : null
}

output "jira_connector_state" {
  description = "The state of the Jira data connector"
  value       = var.enable_jira_connector ? google_discovery_engine_data_connector.jira[0].state : null
}

# -----------------------------------------------------------------------------
# Confluence Connector Outputs
# -----------------------------------------------------------------------------

output "confluence_connector_name" {
  description = "The full resource name of the Confluence data connector"
  value       = var.enable_confluence_connector ? google_discovery_engine_data_connector.confluence[0].name : null
}

output "confluence_connector_state" {
  description = "The state of the Confluence data connector"
  value       = var.enable_confluence_connector ? google_discovery_engine_data_connector.confluence[0].state : null
}

# -----------------------------------------------------------------------------
# Mail Connector Outputs
# -----------------------------------------------------------------------------

output "mail_connector_name" {
  description = "The full resource name of the Gmail data connector"
  value       = var.enable_mail_connector ? google_discovery_engine_data_connector.mail[0].name : null
}

output "mail_connector_state" {
  description = "The state of the Gmail data connector"
  value       = var.enable_mail_connector ? google_discovery_engine_data_connector.mail[0].state : null
}

# -----------------------------------------------------------------------------
# Calendar Connector Outputs
# -----------------------------------------------------------------------------

output "calendar_connector_name" {
  description = "The full resource name of the Calendar data connector"
  value       = var.enable_calendar_connector ? google_discovery_engine_data_connector.calendar[0].name : null
}

output "calendar_connector_state" {
  description = "The state of the Calendar data connector"
  value       = var.enable_calendar_connector ? google_discovery_engine_data_connector.calendar[0].state : null
}

# -----------------------------------------------------------------------------
# Drive Connector Outputs
# -----------------------------------------------------------------------------

output "drive_connector_name" {
  description = "The full resource name of the Drive data connector"
  value       = var.enable_drive_connector ? google_discovery_engine_data_connector.drive[0].name : null
}

output "drive_connector_state" {
  description = "The state of the Drive data connector"
  value       = var.enable_drive_connector ? google_discovery_engine_data_connector.drive[0].state : null
}

# -----------------------------------------------------------------------------
# Salesforce Connector Outputs
# -----------------------------------------------------------------------------

output "salesforce_connector_name" {
  description = "The full resource name of the Salesforce data connector"
  value       = var.enable_salesforce_connector ? google_discovery_engine_data_connector.salesforce[0].name : null
}

output "salesforce_connector_state" {
  description = "The state of the Salesforce data connector"
  value       = var.enable_salesforce_connector ? google_discovery_engine_data_connector.salesforce[0].state : null
}

# -----------------------------------------------------------------------------
# Widget Configuration Outputs
# -----------------------------------------------------------------------------

output "widget_config_id" {
  description = "The ID of the widget configuration"
  value       = var.enable_widget_config ? google_discovery_engine_widget_config.main[0].widget_config_id : null
}

output "widget_config_name" {
  description = "The full resource name of the widget configuration"
  value       = var.enable_widget_config ? google_discovery_engine_widget_config.main[0].name : null
}
