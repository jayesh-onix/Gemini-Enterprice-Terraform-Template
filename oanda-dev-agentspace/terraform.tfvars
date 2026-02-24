# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------
project_id = "oanda-dev-agentspace"

# -----------------------------------------------------------------------------
# Gemini Enterprise Configuration
# -----------------------------------------------------------------------------
discovery_engine_location = "global" # Options: global, us, eu

# Search Engine settings
search_engine_id           = "oanda-enterprise-app"
search_engine_display_name = "Oanda Gemini Enterprise App"

# Collection settings (shared between search engine and data connectors)
collection_id           = "oanda-jira-collection"
collection_display_name = "Oanda Jira"

# -----------------------------------------------------------------------------
# Jira Cloud Data Connector Configuration
# -----------------------------------------------------------------------------
enable_jira_connector = true
jira_instance_id      = "d2899e15-212f-4f61-a694-711d91deedd1" # The Cloud ID you will get from https://YOUR_INSTANCE.atlassian.net/_edge/tenant_info
jira_instance_uri     = "https://oandacorp.atlassian.net"

# Note: Secrets are read from Secret Manager with fixed naming:
# -ONIX_JIRA_INTEGRATION_CLIENTID,
# -ONIX_JIRA_INTEGRATION_SECRET,
# -ONIX_JIRA_INTEGRATION_REFRESH_TOKEN

# Sync intervals
jira_refresh_interval             = "86400s" # Full refresh: daily
jira_incremental_refresh_interval = "21600s" # Incremental: 6 hours

# Entities to sync (valid: project, attachment, comment, issue, bug, epic, story, task, worklog, board)
jira_entities = [
  {
    entity_name = "issue"
    params      = null
  },
  {
    entity_name = "project"
    params      = null
  },
  {
    entity_name = "worklog"
    params      = null
  },

  {
    entity_name = "comment"
    params      = null
  },

  {
    entity_name = "attachment"
    params      = null
  }

]

# Connector settings
jira_static_ip_enabled = false
jira_connector_modes   = ["FEDERATED"] # Options: DATA_INGESTION, FEDERATED
jira_sync_mode         = "PERIODIC"    # Options: PERIODIC, MANUAL


# -----------------------------------------------------------------------------
# Confluence Cloud Data Connector Configuration
# -----------------------------------------------------------------------------
enable_confluence_connector        = true
confluence_instance_id             = "d2899e15-212f-4f61-a694-711d91deedd1"
confluence_instance_uri            = "https://oandacorp.atlassian.net"
confluence_collection_id           = "oanda-confluence-collection"
confluence_collection_display_name = "Oanda Confluence"
# Sync intervals
confluence_refresh_interval             = "86400s"
confluence_incremental_refresh_interval = "21600s"

# Entities to sync (valid: space, page, blog, attachment, comment, whiteboard)
confluence_entities = [
  {
    entity_name = "page"
    params      = null
  },
  {
    entity_name = "space"
    params      = null
  },
  {
    entity_name = "blog"
    params      = null
  },
  {
    entity_name = "attachment"
    params      = null
  },
  {
    entity_name = "whiteboard"
    params      = null
  },
  {
    entity_name = "comment"
    params      = null
  }
]

# Connector settings
confluence_static_ip_enabled = false
confluence_connector_modes   = ["FEDERATED"]
confluence_sync_mode         = "PERIODIC"


enable_mail_connector        = true
mail_collection_id           = "oanda-mail-collection"
mail_collection_display_name = "Oanda Gmail"
mail_refresh_interval        = "3600s"
mail_static_ip_enabled       = false
mail_auto_run_disabled       = false
mail_entity = {
  entity_name = "google_mail"
  params      = null
}

enable_calendar_connector        = true
calendar_collection_id           = "oanda-calendar-collection"
calendar_collection_display_name = "Oanda Calendar"
calendar_refresh_interval        = "3600s"
calendar_static_ip_enabled       = false
calendar_auto_run_disabled       = false
calendar_entity = {
  entity_name = "google_calendar"
  params      = null
}

enable_drive_connector        = true
drive_collection_id           = "oanda-drive-collection"
drive_collection_display_name = "Oanda Drive"
drive_refresh_interval        = "3600s"
drive_static_ip_enabled       = false
drive_auto_run_disabled       = false
drive_entity = {
  entity_name = "google_drive"
  params      = null
}
workspace_connector_modes = ["FEDERATED"]

enable_salesforce_connector             = false
salesforce_collection_id                = "oanda-salesforce-collection"
salesforce_collection_display_name      = "Oanda Salesforce"
salesforce_refresh_interval             = "86400s"
salesforce_incremental_refresh_interval = "10800s"
salesforce_auto_run_disabled            = false
salesforce_entities = [
  {
    entity_name = "lead"
    params      = null
  },
  {
    entity_name = "opportunity"
    params      = null
  },
  {
    entity_name = "task"
    params      = null
  },
  {
    entity_name = "account"
    params      = null
  },
  {
    entity_name = "contact"
    params      = null
  },
  {
    entity_name = "case"
    params      = null
  },
  {
    entity_name = "contentdocument"
    params      = null
  }
]
salesforce_instance_url      = "https://oanda.my.salesforce.com"
salesforce_static_ip_enabled = false
salesforce_connector_modes   = ["DATA_INGESTION"]
salesforce_sync_mode         = "PERIODIC"

# -----------------------------------------------------------------------------
# Widget Configuration
# -----------------------------------------------------------------------------
enable_widget_config           = true
widget_config_id               = "default_search_widget_config"
widget_enable_web_app          = true
widget_allow_public_access     = false
widget_allowlisted_domains     = []
widget_interaction_type        = "SEARCH_WITH_ANSWER" # Options: SEARCH_ONLY, SEARCH_WITH_ANSWER, SEARCH_WITH_FOLLOW_UPS
widget_enable_autocomplete     = true
widget_enable_quality_feedback = true
widget_enable_safe_search      = true

# Custom branding logo (optional - set to a publicly accessible URL)
widget_logo_url = "https://www.oanda.com/assets/images/oanda-logo-dark.6b7ab1315e0d.svg"

# Homepage shortcuts (optional)
widget_homepage_shortcuts = []
# Example:
# widget_homepage_shortcuts = [
#   {
#     title           = "Documentation"
#     destination_uri = "https://docs.example.com"
#   },
#   {
#     title           = "Support"
#     destination_uri = "https://support.example.com"
#   }
# ]

bq_agent_datasets = [
  "oanda-dev-de.onix_bronze"
]
