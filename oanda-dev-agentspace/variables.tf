# -----------------------------------------------------------------------------
# Required Variables
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
  default     = "gemini-enterprise-app-v1"
}

variable "search_engine_display_name" {
  description = "Display name for the Gemini Enterprise search engine"
  type        = string
  default     = "Gemini Enterprise Search"
}

variable "collection_id" {
  description = "Collection ID for the search engine and data connectors (shared collection for linking)"
  type        = string
  default     = "default_collection"
}

variable "collection_display_name" {
  description = "Display name for the collection"
  type        = string
  default     = "Default Collection"
}

# -----------------------------------------------------------------------------
# Jira Cloud Data Connector Configuration
# -----------------------------------------------------------------------------

variable "enable_jira_connector" {
  description = "Whether to create a Jira Cloud data connector"
  type        = bool
  default     = false
}

variable "jira_instance_id" {
  description = "The Jira Cloud instance ID (the subdomain part of your Atlassian URL, e.g., 'your-domain' from https://your-domain.atlassian.net)"
  type        = string
  default     = ""
}

variable "jira_instance_uri" {
  description = "The Jira Cloud instance URI (e.g., https://your-domain.atlassian.net)"
  type        = string
  default     = ""
}

# Note: Jira OAuth secrets are read from Secret Manager with fixed naming:
# - ONIX_JIRA_INTEGRATION_CLIENTID,
# - ONIX_JIRA_INTEGRATION_SECRET,
# - ONIX_JIRA_INTEGRATION_REFRESH_TOKEN

variable "jira_refresh_interval" {
  description = "Full refresh interval for Jira data sync (e.g., 86400s for daily)"
  type        = string
  default     = "86400s"
}

variable "jira_incremental_refresh_interval" {
  description = "Incremental refresh interval for Jira data sync (e.g., 21600s for 6 hours)"
  type        = string
  default     = "21600s"
}

variable "jira_entities" {
  description = "List of Jira entities to sync. Valid types: project, attachment, comment, issue, bug, epic, story, task, worklog, board"
  type = list(object({
    entity_name = string
    params      = optional(string, null)
  }))
  default = [
    {
      entity_name = "issue"
      params      = null
    }
  ]
  validation {
    condition = alltrue([
      for entity in var.jira_entities : contains(
        ["project", "attachment", "comment", "issue", "bug", "epic", "story", "task", "worklog", "board"],
        entity.entity_name
      )
    ])
    error_message = "Entity type must be one of: project, attachment, comment, issue, bug, epic, story, task, worklog, board."
  }
}

variable "jira_static_ip_enabled" {
  description = "Whether to use static IP for Jira connector"
  type        = bool
  default     = false
}

variable "jira_connector_modes" {
  description = "Connector modes for Jira (DATA_INGESTION, FEDERATED)"
  type        = list(string)
  default     = ["FEDERATED"]
}

variable "jira_sync_mode" {
  description = "Sync mode for Jira connector (PERIODIC, MANUAL)"
  type        = string
  default     = "PERIODIC"
}


# -----------------------------------------------------------------------------
# Confluence Cloud Data Connector Configuration
# -----------------------------------------------------------------------------

variable "enable_confluence_connector" {
  description = "Whether to create a Confluence Cloud data connector"
  type        = bool
  default     = false
}

variable "confluence_instance_id" {
  description = "The Confluence Cloud instance ID (often a UUID or subdomain identifier)"
  type        = string
  default     = ""
}

variable "confluence_instance_uri" {
  description = "The Confluence Cloud instance URI (e.g., https://your-domain.atlassian.net)"
  type        = string
  default     = ""
}

variable "confluence_collection_id" {
  description = "Collection id for confluence connector"
  type        = string
  default     = "confluence_default_collection"
}

variable "confluence_collection_display_name" {
  description = "Collection display name for confluence connector"
  type        = string
  default     = "Default collection for Confluence"
}

# Note: Confluence OAuth secrets are read from Secret Manager with fixed naming:
# - ONIX_CONFLUENCE_INTEGRATION_CLIENTID
# - ONIX_CONFLUENCE_INTEGRATION_SECRET
# - ONIX_CONFLUENCE_INTEGRATION_REFRESH_TOKEN

variable "confluence_refresh_interval" {
  description = "Full refresh interval for Confluence data sync (e.g., 86400s for daily)"
  type        = string
  default     = "86400s"
}

variable "confluence_incremental_refresh_interval" {
  description = "Incremental refresh interval for Confluence data sync"
  type        = string
  default     = "21600s"
}

variable "confluence_entities" {
  description = "List of Confluence entities to sync. Valid types: space, page, blog, attachment, comment, whiteboard"
  type = list(object({
    entity_name = string
    params      = optional(string, null)
  }))
  default = [
    {
      entity_name = "page"
      params      = null
    }
  ]
  validation {
    condition = alltrue([
      for entity in var.confluence_entities : contains(
        ["space", "page", "blog", "attachment", "comment", "whiteboard"],
        entity.entity_name
      )
    ])
    error_message = "Entity type must be one of: space, page, blog, attachment, comment, whiteboard"
  }
}

variable "confluence_static_ip_enabled" {
  description = "Whether to use static IP for Confluence connector"
  type        = bool
  default     = false
}

variable "confluence_connector_modes" {
  description = "Connector modes for Confluence (DATA_INGESTION, FEDERATED)"
  type        = list(string)
  default     = ["FEDERATED"]
}

variable "confluence_sync_mode" {
  description = "Sync mode for Confluence connector (PERIODIC, MANUAL)"
  type        = string
  default     = "PERIODIC"
}

# -----------------------------------------------------------------------------
# Gmail Data Connector Configuration
# -----------------------------------------------------------------------------
variable "enable_mail_connector" {
  description = "Whether to create a mail data connector"
  type        = bool
  default     = false
}
variable "mail_collection_id" {
  description = "Collection id for gmail connector"
  type        = string
  default     = "default_collection"
}
variable "mail_collection_display_name" {
  description = "Collection display name for mail connector"
  type        = string
  default     = "Default collection for mail"
}
variable "mail_refresh_interval" {
  description = "Full refresh interval for Mail data sync (e.g., 86400s for daily)"
  type        = string
  default     = "86400s"
}
variable "mail_static_ip_enabled" {
  description = "Whether to use static IP for Gmail connector"
  type        = bool
  default     = false
}
variable "mail_auto_run_disabled" {
  description = "Whether to disable full sync for Gmail data connector"
  type        = bool
  default     = false
}
variable "mail_entity" {
  description = "Gmail entity configuration. The only valid entity_name is \"google_mail\"."
  type = object({
    entity_name = string
    params      = optional(string)
  })

  default = {
    entity_name = "google_mail"
    params      = null
  }

}
# -----------------------------------------------------------------------------
# Calendar Data Connector Configuration
# -----------------------------------------------------------------------------
variable "enable_calendar_connector" {
  description = "Whether to create a calendar data connector"
  type        = bool
  default     = false
}
variable "calendar_collection_id" {
  description = "Collection id for calendar connector"
  type        = string
  default     = "default_collection"
}
variable "calendar_collection_display_name" {
  description = "Collection display name for calendar connector"
  type        = string
  default     = "Default collection for calendar"
}
variable "calendar_refresh_interval" {
  description = "Full refresh interval for Calendar data sync (e.g., 86400s for daily)"
  type        = string
  default     = "86400s"
}
variable "calendar_static_ip_enabled" {
  description = "Whether to use static IP for Calendar connector"
  type        = bool
  default     = false
}
variable "calendar_auto_run_disabled" {
  description = "Whether to disable full sync for Calendar data connector"
  type        = bool
  default     = false
}
variable "calendar_entity" {
  description = "Google Calendar entity configuration. The only valid entity_name is \"google_calendar\"."
  type = object({
    entity_name = string
    params      = optional(string)
  })

  default = {
    entity_name = "google_calendar"
    params      = null
  }

}
# -----------------------------------------------------------------------------
# Drive Data Connector Configuration
# -----------------------------------------------------------------------------
variable "enable_drive_connector" {
  description = "Whether to create a drive data connector"
  type        = bool
  default     = false
}
variable "drive_collection_id" {
  description = "Collection id for drive connector"
  type        = string
  default     = "default_collection"
}
variable "drive_collection_display_name" {
  description = "Collection display name for drive connector"
  type        = string
  default     = "Default collection for drive"
}
variable "drive_refresh_interval" {
  description = "Full refresh interval for Drive data sync (e.g., 86400s for daily)"
  type        = string
  default     = "86400s"
}
variable "drive_static_ip_enabled" {
  description = "Whether to use static IP for Drive connector"
  type        = bool
  default     = false
}
variable "drive_auto_run_disabled" {
  description = "Whether to disable full sync for Drive data connector"
  type        = bool
  default     = false
}
variable "drive_entity" {
  description = "Google Drive entity configuration. The only valid entity_name is \"google_drive\"."
  type = object({
    entity_name = string
    params      = optional(string)
  })

  default = {
    entity_name = "google_drive"
    params      = null
  }
}
variable "workspace_connector_modes" {
  description = "Connector modes for Workspace (DATA_INGESTION, FEDERATED)"
  type        = list(string)
  default     = ["FEDERATED"]
}
# -----------------------------------------------------------------------------
# Salesforce Data Connector Configuration
# -----------------------------------------------------------------------------
variable "enable_salesforce_connector" {
  description = "Whether to create a salesforce data connector"
  type        = bool
  default     = false
}
variable "salesforce_collection_id" {
  description = "Collection id for salesforce connector"
  type        = string
  default     = "default_collection"
}
variable "salesforce_collection_display_name" {
  description = "Collection display name for salesforce connector"
  type        = string
  default     = "Default collection for salesforce"
}
variable "salesforce_refresh_interval" {
  description = "Full refresh interval for Salesforce data sync (e.g., 86400s for daily)"
  type        = string
  default     = "86400s"
}
variable "salesforce_incremental_refresh_interval" {
  description = "Incremental refresh interval for Salesforce data sync (e.g., 21600s for 6 hours)"
  type        = string
  default     = "10800s"
}
variable "salesforce_static_ip_enabled" {
  description = "Whether to use static IP for Salesforce connector"
  type        = bool
  default     = false
}
variable "salesforce_auto_run_disabled" {
  description = "Whether to disable full sync for Salesforce data connector"
  type        = bool
  default     = false
}
variable "salesforce_entities" {
  description = "List of Salesforce entities to sync. Valid types: account, case, contact, contentdocument, lead, opportunity, task"
  type = list(object({
    entity_name = string
    params      = optional(string, null)
  }))
  default = [
    {
      entity_name = "account"
      params      = null
    }
  ]
  validation {
    condition = alltrue([
      for entity in var.salesforce_entities : contains(
        ["account", "case", "contact", "contentdocument", "lead", "opportunity", "task"],
        entity.entity_name
      )
    ])
    error_message = "Entity type must be one of: account, case, contact, contentdocument, lead, opportunity, task"
  }
}
variable "salesforce_instance_url" {
  description = "The Salesforce instance URL (e.g., 'https://yourinstance.salesforce.com')"
  type        = string
  default     = "https://login.salesforce.com"
}

variable "salesforce_connector_modes" {
  description = "Connector modes for Salesforce (DATA_INGESTION, FEDERATED)"
  type        = list(string)
  default     = ["FEDERATED"]
}

variable "salesforce_sync_mode" {
  description = "Sync mode for Salesforce connector (PERIODIC, MANUAL)"
  type        = string
  default     = "PERIODIC"
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
  description = "Type of search interaction (SEARCH_ONLY, SEARCH_WITH_ANSWER, SEARCH_WITH_FOLLOW_UPS)"
  type        = string
  default     = "SEARCH_WITH_ANSWER"
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
  description = "URL of the logo image to display in the widget (must be a publicly accessible URL)"
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

# -----------------------------------------------------------------------------
# BigQuery Agent Service Account Configuration
# -----------------------------------------------------------------------------
variable "bq_agent_datasets" {
  description = "List of BigQuery dataset IDs to grant the oanda-bq-agent service account Data Viewer access"
  type        = list(string)
  default     = []
}
