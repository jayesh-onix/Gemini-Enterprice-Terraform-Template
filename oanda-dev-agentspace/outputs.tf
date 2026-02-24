# -----------------------------------------------------------------------------
# Gemini Enterprise Module Outputs
# -----------------------------------------------------------------------------
output "license_config_id" {
  description = "The ID of the Gemini Enterprise license configuration"
  value       = module.gemini_enterprise.license_config_id
}

output "license_config_name" {
  description = "The full resource name of the license configuration"
  value       = module.gemini_enterprise.license_config_name
}

output "search_engine_id" {
  description = "The ID of the Discovery Engine search engine"
  value       = module.gemini_enterprise.engine_id
}

output "search_engine_name" {
  description = "The full resource name of the Discovery Engine search engine"
  value       = module.gemini_enterprise.engine_name
}

output "search_engine_display_name" {
  description = "The display name of the search engine"
  value       = module.gemini_enterprise.engine_display_name
}

# -----------------------------------------------------------------------------
# Connection Information
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
  description = "URL to the Vertex AI Search webapp for end users"
  value       = module.gemini_enterprise.vertex_ai_search_url
}

output "engine_full_id" {
  description = "The full resource ID of the search engine"
  value       = module.gemini_enterprise.engine_full_id
}

# -----------------------------------------------------------------------------
# BigQuery Agent Service Account
# -----------------------------------------------------------------------------
output "bq_agent_service_account_email" {
  description = "The email address of the BigQuery agent service account"
  value       = google_service_account.oanda_bq_agent.email
}

output "bq_agent_service_account_name" {
  description = "The fully-qualified name of the BigQuery agent service account"
  value       = google_service_account.oanda_bq_agent.name
}

output "bq_agent_datasets" {
  description = "List of BigQuery datasets the agent service account has access to"
  value       = var.bq_agent_datasets
}

# -----------------------------------------------------------------------------
# API Agent Service Account
# -----------------------------------------------------------------------------

output "api_agent_service_account_name" {
  description = "The fully-qualified name of the API agent service account"
  value       = google_service_account.oanda_api_agent.name
}

output "api_agent_service_account_email" {
  description = "Email of the API agent service account"
  value       = google_service_account.oanda_api_agent.email
}
