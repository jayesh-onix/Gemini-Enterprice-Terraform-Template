terraform {
  backend "gcs" {
    bucket = "oanda-dev-tfstate"
    prefix = "oanda-dev-agentspace-onix"
  }
}
# -----------------------------------------------------------------------------
# Gemini Enterprise Module
# -----------------------------------------------------------------------------
module "gemini_enterprise" {
  source = "./modules/gemini-enterprise"

  project_id = var.project_id
  engine_id  = var.search_engine_id
  location   = var.discovery_engine_location

  # License configuration (disabled by default - enable when ready)
  enable_license_config = false
  license_count         = 25
  free_trial            = true
  subscription_tier     = "SUBSCRIPTION_TIER_ENTERPRISE"
  subscription_term     = "SUBSCRIPTION_TERM_ONE_MONTH"

  start_date = {
    year  = 2025
    month = 12
    day   = 27
  }
  end_date = {
    year  = 2026
    month = 1
    day   = 26
  }

  # Search engine configuration
  engine_display_name     = var.search_engine_display_name
  collection_id           = var.collection_id
  collection_display_name = var.collection_display_name
  app_type                = "APP_TYPE_INTRANET"
  search_tier             = "SEARCH_TIER_ENTERPRISE"
  search_add_ons          = ["SEARCH_ADD_ON_LLM"]

  # Jira Cloud Connector (uses same collection for data store linking)
  # Secrets are read from Secret Manager: ONIX_JIRA_INTEGRATION_CLIENTID, ONIX_JIRA_INTEGRATION_SECRET, ONIX_JIRA_INTEGRATION_REFRESH_TOKEN
  enable_jira_connector             = var.enable_jira_connector
  jira_instance_id                  = var.jira_instance_id
  jira_instance_uri                 = var.jira_instance_uri
  jira_refresh_interval             = var.jira_refresh_interval
  jira_incremental_refresh_interval = var.jira_incremental_refresh_interval
  jira_entities                     = var.jira_entities
  jira_static_ip_enabled            = var.jira_static_ip_enabled
  jira_connector_modes              = var.jira_connector_modes
  jira_sync_mode                    = var.jira_sync_mode

  # Confluence Cloud Connector (uses same collection for data store linking)
  # Secrets are read from Secret Manager: ONIX_CONFLUENCE_INTEGRATION_CLIENTID, ONIX_CONFLUENCE_INTEGRATION_SECRET, ONIX_CONFLUENCE_INTEGRATION_REFRESH_TOKEN
  enable_confluence_connector             = var.enable_confluence_connector
  confluence_instance_id                  = var.confluence_instance_id
  confluence_instance_uri                 = var.confluence_instance_uri
  confluence_collection_id                = var.confluence_collection_id
  confluence_collection_display_name      = var.confluence_collection_display_name
  confluence_refresh_interval             = var.confluence_refresh_interval
  confluence_incremental_refresh_interval = var.confluence_incremental_refresh_interval
  confluence_entities                     = var.confluence_entities
  confluence_static_ip_enabled            = var.confluence_static_ip_enabled
  confluence_connector_modes              = var.confluence_connector_modes
  confluence_sync_mode                    = var.confluence_sync_mode




  enable_mail_connector        = var.enable_mail_connector
  mail_collection_id           = var.mail_collection_id
  mail_collection_display_name = var.mail_collection_display_name
  mail_refresh_interval        = var.mail_refresh_interval
  mail_static_ip_enabled       = var.mail_static_ip_enabled
  mail_auto_run_disabled       = var.mail_auto_run_disabled
  mail_entity                  = var.mail_entity

  enable_calendar_connector        = var.enable_calendar_connector
  calendar_collection_id           = var.calendar_collection_id
  calendar_collection_display_name = var.calendar_collection_display_name
  calendar_refresh_interval        = var.calendar_refresh_interval
  calendar_static_ip_enabled       = var.calendar_static_ip_enabled
  calendar_auto_run_disabled       = var.calendar_auto_run_disabled
  calendar_entity                  = var.calendar_entity

  enable_drive_connector        = var.enable_drive_connector
  drive_collection_id           = var.drive_collection_id
  drive_collection_display_name = var.drive_collection_display_name
  drive_refresh_interval        = var.drive_refresh_interval
  drive_static_ip_enabled       = var.drive_static_ip_enabled
  drive_auto_run_disabled       = var.drive_auto_run_disabled
  drive_entity                  = var.drive_entity
  workspace_connector_modes     = var.workspace_connector_modes

  enable_salesforce_connector             = var.enable_salesforce_connector
  salesforce_collection_id                = var.salesforce_collection_id
  salesforce_collection_display_name      = var.salesforce_collection_display_name
  salesforce_refresh_interval             = var.salesforce_refresh_interval
  salesforce_incremental_refresh_interval = var.salesforce_incremental_refresh_interval
  salesforce_auto_run_disabled            = var.salesforce_auto_run_disabled
  salesforce_entities                     = var.salesforce_entities
  salesforce_instance_url                 = var.salesforce_instance_url
  salesforce_static_ip_enabled            = var.salesforce_static_ip_enabled
  salesforce_connector_modes              = var.salesforce_connector_modes
  salesforce_sync_mode                    = var.salesforce_sync_mode

  # Widget configuration
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

module "adk_agent_bucket" {
  source                   = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  project_id               = var.project_id
  version                  = "~> 12.1"
  location                 = "US"
  name                     = "oanda-dev-adk-agent-ge"
  storage_class            = "STANDARD"
  public_access_prevention = "enforced"

  iam_members = [
    {
      role   = "roles/storage.objectUser"
      member = "serviceAccount:${google_service_account.oanda_dev_agent_sa.email}"
    }
  ]

  versioning         = false
  bucket_policy_only = true
  force_destroy      = false
  labels = {
    environment = "dev"
    owner       = "sre"
    platform    = "live"
  }
}

resource "google_project_iam_member" "agent_project_roles" {
  for_each = toset([
    "roles/discoveryengine.editor",
    "roles/logging.logWriter",
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.serviceAccountUser",
    "roles/serviceusage.serviceUsageConsumer",
    "roles/aiplatform.user"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.oanda_dev_agent_sa.email}"
}

resource "google_service_account" "oanda_dev_agent_sa" {
  project      = var.project_id
  account_id   = "oanda-dev-agent-sa"
  display_name = "Oanda Dev Agent SA"
  description  = "This Service Account provides the necessary permissions for CircleCI pipelines to authenticate with GCP and use Cloud Storage bucket"
}

resource "google_service_account_key" "oanda_dev_agent_sa_key" {
  service_account_id = google_service_account.oanda_dev_agent_sa.name
}

resource "google_secret_manager_secret" "oanda_dev_agent_sa_secret" {
  project   = var.project_id
  secret_id = "OANDA_DEV_AGENT_SERVICE_ACCOUNT"
  replication {
    auto {}
  }
  labels = {
    owner       = "sre"
    environment = "dev"
  }
}

resource "google_secret_manager_secret_version" "oanda_dev_agent_sa_secret_version" {
  secret      = google_secret_manager_secret.oanda_dev_agent_sa_secret.id
  secret_data = base64decode(google_service_account_key.oanda_dev_agent_sa_key.private_key)
}

# -----------------------------------------------------------------------------
# IAM Bindings for Gemini Enterprise Users and Admins
# -----------------------------------------------------------------------------
resource "google_project_iam_member" "ge_users" {
  project = var.project_id
  role    = "roles/discoveryengine.user"
  member  = "group:gcp-agentspace-users@oanda.com"
}

resource "google_project_iam_member" "ge_admins" {
  project = var.project_id
  role    = "roles/discoveryengine.admin"
  member  = "group:gcp-agentspace-admins@oanda.com"
}

resource "google_project_iam_member" "ge_admins_service_usage" {
  project = var.project_id
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "group:gcp-agentspace-admins@oanda.com"
}

resource "google_project_iam_member" "ge_users_service_usage" {
  project = var.project_id
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "group:gcp-agentspace-users@oanda.com"
}

# -----------------------------------------------------------------------------
# API Agent Service Account
# -----------------------------------------------------------------------------
resource "google_service_account" "oanda_api_agent" {
  project      = var.project_id
  account_id   = "oanda-api-agent"
  display_name = "OANDA API Agent"
  description  = "Service account for Vertex AI Search API agent access"
}

resource "google_project_iam_member" "api_agent_discovery_engine_editor" {
  project = var.project_id
  role    = "roles/discoveryengine.editor"
  member  = "serviceAccount:${google_service_account.oanda_api_agent.email}"
}

resource "google_project_iam_member" "api_agent_logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.oanda_api_agent.email}"
}

resource "google_project_iam_member" "api_agent_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.oanda_api_agent.email}"
}

resource "google_project_iam_member" "api_agent_sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.oanda_api_agent.email}"
}

resource "google_project_iam_member" "api_agent_service_usage" {
  project = var.project_id
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "serviceAccount:${google_service_account.oanda_api_agent.email}"
}

resource "google_project_iam_member" "api_agent_aiplatform_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.oanda_api_agent.email}"
}

# -----------------------------------------------------------------------------
# BigQuery Agent Service Account
# -----------------------------------------------------------------------------
resource "google_service_account" "oanda_bq_agent" {
  project      = var.project_id
  account_id   = "oanda-bq-agent"
  display_name = "OANDA BigQuery Agent"
  description  = "Service account for BigQuery data access"
}

resource "google_project_iam_member" "bq_agent_telemetry_writer" {
  project = var.project_id
  role    = "roles/telemetry.writer"
  member  = "serviceAccount:${google_service_account.oanda_bq_agent.email}"
}

resource "google_project_iam_member" "bq_agent_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.oanda_bq_agent.email}"
}

resource "google_project_iam_member" "bq_agent_service_usage_consumer" {
  project = var.project_id
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "serviceAccount:${google_service_account.oanda_bq_agent.email}"
}

resource "google_project_iam_member" "bq_agent_vertex_ai_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.oanda_bq_agent.email}"
}
