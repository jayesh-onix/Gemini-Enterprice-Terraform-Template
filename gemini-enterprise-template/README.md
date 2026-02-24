# Gemini Enterprise Terraform Template

Production-ready, generic Terraform template for automating Google Gemini Enterprise (Discovery Engine) deployments with data connectors.

## Overview

This template provisions:

- **Gemini Enterprise License** (optional) — configurable subscription tier, term, and seat count
- **Discovery Engine Search Engine** — enterprise search with LLM capabilities
- **Data Connectors** — third-party (Jira, Confluence, Salesforce) and Google Workspace (Gmail, Calendar, Drive)
- **Search Widget** — embeddable UI with branding, autocomplete, and answer modes

### Key Design Principles

| Principle | How |
|-----------|-----|
| **Config-driven** | All connectors configured via `terraform.tfvars` — zero code changes needed |
| **No duplication** | Single generic `for_each` resource replaces 6 connector-specific files |
| **Flexible secrets** | Secret Manager names are configurable per connector, not hardcoded |
| **Multi-environment** | Use `-var-file` for dev/staging/prod with shared codebase |
| **Extensible** | Add new connectors by adding entries to the config map |

## Directory Structure

```
gemini-enterprise-template/
├── main.tf                          # Module invocation (rarely modified)
├── variables.tf                     # Root variables
├── outputs.tf                       # Root outputs
├── providers.tf                     # Google provider config
├── versions.tf                      # Terraform & provider versions
├── terraform.tfvars.example         # Full config example (copy to terraform.tfvars)
├── .gitignore
├── environments/
│   ├── dev.tfvars.example           # Development environment example
│   └── prod.tfvars.example          # Production environment example
└── modules/
    └── gemini-enterprise/
        ├── main.tf                  # License + Search Engine + Widget
        ├── connectors.tf            # Unified connector resource (all types)
        ├── locals.tf                # Computed values, data store IDs
        ├── variables.tf             # Module variables with full validation
        ├── outputs.tf               # Module outputs
        └── versions.tf              # Provider constraints
```

## Quick Start

### 1. Copy the template

```bash
cp -r gemini-enterprise-template/ my-project-agentspace/
cd my-project-agentspace/
```

### 2. Create your config

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` — set your `project_id` and enable the connectors you need.

### 3. Set up secrets (for third-party connectors)

Before applying, create the required secrets in GCP Secret Manager:

```bash
# Example for Jira
echo -n "your-client-id" | gcloud secrets create YOUR_PROJECT_JIRA_CLIENT_ID \
  --project=your-project --data-file=-

echo -n "your-client-secret" | gcloud secrets create YOUR_PROJECT_JIRA_CLIENT_SECRET \
  --project=your-project --data-file=-

echo -n "your-refresh-token" | gcloud secrets create YOUR_PROJECT_JIRA_REFRESH_TOKEN \
  --project=your-project --data-file=-
```

### 4. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 5. Multi-environment deployment

```bash
# Dev
terraform plan -var-file="environments/dev.tfvars"

# Production
terraform plan -var-file="environments/prod.tfvars"
```

## Configuration Guide

### Connector Types

#### Third-Party Connectors (OAuth-based)

These connectors authenticate via OAuth credentials stored in Secret Manager.

| Connector | `data_source` | Auth Type | Required Secrets |
|-----------|---------------|-----------|-----------------|
| Jira Cloud | `jira` | 3-legged OAuth | `client_id`, `client_secret`, `refresh_token` |
| Confluence Cloud | `confluence` | 3-legged OAuth | `client_id`, `client_secret`, `refresh_token` |
| Salesforce | `salesforce` | 2-legged OAuth | `client_id`, `client_secret` |

**Configuration structure:**

```hcl
third_party_connectors = {
  my_connector = {
    enabled                      = true
    data_source                  = "jira"              # Connector type
    collection_id                = "my-collection"      # Unique ID
    collection_display_name      = "My Collection"
    params = {                                          # Non-secret params
      instance_uri = "https://example.atlassian.net"
      instance_id  = "cloud-id-uuid"
    }
    secrets = {                                         # Secret Manager IDs
      client_id     = "MY_JIRA_CLIENT_ID"
      client_secret = "MY_JIRA_CLIENT_SECRET"
      refresh_token = "MY_JIRA_REFRESH_TOKEN"
    }
    refresh_interval             = "86400s"
    incremental_refresh_interval = "21600s"
    entities = [
      { entity_name = "issue" },
      { entity_name = "project" }
    ]
    connector_modes = ["FEDERATED"]
    sync_mode       = "PERIODIC"
  }
}
```

#### Google Workspace Connectors (Native)

No OAuth secrets required — these use the project's Google Workspace identity.

| Connector | `data_source` | `entity_name` |
|-----------|---------------|----------------|
| Gmail | `google_mail` | `google_mail` |
| Calendar | `google_calendar` | `google_calendar` |
| Drive | `google_drive` | `google_drive` |

**Configuration structure:**

```hcl
workspace_connectors = {
  gmail = {
    enabled                 = true
    data_source             = "google_mail"
    collection_id           = "mail-collection"
    collection_display_name = "Gmail"
    refresh_interval        = "3600s"
    entity                  = { entity_name = "google_mail" }
    connector_modes         = ["FEDERATED"]
  }
}
```

### Enabling/Disabling Connectors

Set `enabled = false` on any connector to skip its creation:

```hcl
third_party_connectors = {
  jira = {
    enabled = false   # Connector will not be created
    # ... rest of config preserved for future use
  }
}
```

Or simply remove the connector entry from the map entirely.

### Widget Configuration

```hcl
enable_widget_config       = true
widget_interaction_type    = "SEARCH_WITH_ANSWER"   # SEARCH_ONLY | SEARCH_WITH_ANSWER | SEARCH_WITH_FOLLOW_UPS
widget_enable_web_app      = true
widget_allow_public_access = false
widget_logo_url            = "https://example.com/logo.svg"

widget_homepage_shortcuts = [
  {
    title           = "Docs"
    destination_uri = "https://docs.example.com"
  }
]
```

### Remote State Backend

Uncomment and configure the backend block in `versions.tf`:

```hcl
terraform {
  backend "gcs" {
    bucket = "your-terraform-state-bucket"
    prefix = "gemini-enterprise/your-project"
  }
}
```

## Valid Entity Names

### Jira
`project`, `attachment`, `comment`, `issue`, `bug`, `epic`, `story`, `task`, `worklog`, `board`

### Confluence
`space`, `page`, `blog`, `attachment`, `comment`, `whiteboard`

### Salesforce
`account`, `case`, `contact`, `contentdocument`, `lead`, `opportunity`, `task`

### Google Workspace
- Gmail: `google_mail`
- Calendar: `google_calendar`
- Drive: `google_drive`

## GCP APIs Required

Enable these APIs in your GCP project before deploying:

```bash
gcloud services enable \
  discoveryengine.googleapis.com \
  secretmanager.googleapis.com \
  --project=your-project-id
```

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.7.0 |
| google provider | >= 6.0, < 8.0 |
| google-beta provider | >= 6.0, < 8.0 |

## Outputs

| Output | Description |
|--------|-------------|
| `search_engine_id` | The ID of the Discovery Engine search engine |
| `gemini_enterprise_console_url` | URL to the Gemini Enterprise console |
| `vertex_ai_search_url` | URL to the Vertex AI Search webapp |
| `third_party_connector_names` | Map of third-party connector resource names |
| `workspace_connector_names` | Map of workspace connector resource names |
| `linked_data_store_ids` | All data store IDs linked to the search engine |
| `widget_config_id` | The widget configuration ID |

## Architecture Comparison

### Before (Oanda-specific template)
- **6 separate connector files** with duplicated resource definitions
- **~1,200 lines** of duplicated variables (module + root)
- **Hardcoded secret names** (e.g., `ONIX_JIRA_INTEGRATION_CLIENTID`)
- Adding a new connector required modifying 4+ files

### After (Generic template)
- **1 unified connector file** using `for_each`
- **~300 lines** of variables (structured maps with defaults)
- **Configurable secret names** per connector
- Adding a new connector = adding an entry in `terraform.tfvars`

## Troubleshooting

### Secret not found
```
Error: google_secret_manager_secret: Not found
```
Ensure the secret exists in your GCP project and the name in your `secrets` map matches exactly.

### Discovery Engine API not enabled
```
Error: googleapi: Error 403: Discovery Engine API has not been enabled
```
Run: `gcloud services enable discoveryengine.googleapis.com --project=your-project`

### Data store not found during engine creation
This usually means a connector has failed to create its data stores. Check the connector state in the console and ensure credentials are valid.

## License

See [LICENSE.txt](../LICENSE.txt) for details.
