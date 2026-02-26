# Gemini Enterprise Terraform Template

A production-ready, **generic and reusable** Terraform template for deploying Google Gemini Enterprise (Discovery Engine) with data connectors — configurable entirely through a single `terraform.tfvars` file. No source code edits needed.

## What This Template Deploys

| Resource | Description |
|----------|-------------|
| **Gemini Enterprise License** | Optional — configurable tier, term, and seat count |
| **Discovery Engine Search Engine** | Enterprise search with LLM (Gemini) capabilities |
| **Third-Party Connectors** | Jira, Confluence, Salesforce (OAuth via Secret Manager) |
| **Google Workspace Connectors** | Gmail, Calendar, Drive (native — no secrets needed) |
| **Search Widget** | Embeddable UI with branding, autocomplete, and Q&A modes |

## Key Design Principles

| Principle | What It Means for You |
|-----------|----------------------|
| **Config-driven** | Enable/disable/configure any connector in `terraform.tfvars` — no code changes ever needed |
| **No code duplication** | One generic `for_each` resource handles all connectors instead of one file per connector |
| **Flexible secret names** | You choose your Secret Manager naming convention — nothing is hardcoded |
| **Multi-environment ready** | Use `-var-file=environments/dev.tfvars` to manage dev, staging, and prod separately |
| **Extensible** | Add a new connector type by adding one entry to the config map — nothing else changes |

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Directory Structure](#directory-structure)
3. [Quick Start (5 Steps)](#quick-start-5-steps)
4. [Step-by-Step Configuration Guide](#step-by-step-configuration-guide)
   - [Third-Party Connectors (Jira, Confluence, Salesforce)](#third-party-connectors-jira-confluence-salesforce)
   - [Google Workspace Connectors (Gmail, Calendar, Drive)](#google-workspace-connectors-gmail-calendar-drive)
   - [Widget Configuration](#widget-configuration)
   - [License Configuration](#license-configuration)
5. [Multi-Environment Deployment](#multi-environment-deployment)
6. [Valid Entity Names](#valid-entity-names)
7. [GCP APIs to Enable](#gcp-apis-to-enable)
8. [Remote State Backend](#remote-state-backend)
9. [Outputs](#outputs)
10. [Troubleshooting](#troubleshooting)
11. [Requirements](#requirements)

---

## Prerequisites

Before you start, make sure you have:

- [ ] **Terraform >= 1.7.0** installed — [Install guide](https://developer.hashicorp.com/terraform/install)
- [ ] **Google Cloud SDK** installed and authenticated — `gcloud auth application-default login`
- [ ] A **GCP Project** with billing enabled
- [ ] **Owner or Editor** IAM role on the GCP project (for initial setup)
- [ ] **GCP APIs enabled** (see [GCP APIs to Enable](#gcp-apis-to-enable))
- [ ] For third-party connectors: secrets created in **GCP Secret Manager** before applying

---

## Directory Structure

```
gemini-enterprise-template/
├── main.tf                     # Calls the gemini-enterprise module — rarely needs editing
├── variables.tf                # Root input variables
├── outputs.tf                  # Root outputs (URLs, IDs, connector states)
├── providers.tf                # Google + Google-Beta provider configuration
├── versions.tf                 # Terraform and provider version constraints
├── terraform.tfvars            # YOUR configuration — edit this file
├── terraform.tfvars.example    # Full reference example with all options documented
├── environments/
│   ├── dev.tfvars.example      # Dev environment example (free trial, fewer seats)
│   └── prod.tfvars.example     # Prod environment example (full license, all connectors)
└── modules/
    └── gemini-enterprise/
        ├── main.tf             # License + Search Engine + Widget resources
        ├── connectors.tf       # ALL connectors in one file (third-party + workspace)
        ├── locals.tf           # Computed values: data store IDs, secret flattening
        ├── variables.tf        # Module input variables with full validation
        ├── outputs.tf          # Module outputs
        └── versions.tf         # Provider version constraints for the module
```

> **The only file you need to edit is `terraform.tfvars`.**  
> All connector configuration, secrets, entities, and feature flags live there.

---


## Quick Start (5 Steps)

### Step 1 — Copy the template into your project folder

```bash
cp -r gemini-enterprise-template/ my-project-agentspace/
cd my-project-agentspace/
```

### Step 2 — Enable required GCP APIs

```bash
gcloud services enable \
  discoveryengine.googleapis.com \
  secretmanager.googleapis.com \
  --project=YOUR_PROJECT_ID
```

### Step 3 — Create your configuration file

```bash
cp terraform.tfvars.example terraform.tfvars
```

Open `terraform.tfvars` and:
1. Set `project_id` to your GCP project ID
2. Set `enabled = true` on the connectors you want to activate
3. Fill in the connection parameters (`instance_uri`, `instance_id`, etc.)
4. Set the `secrets` map to the names of your Secret Manager secrets

### Step 4 — Create secrets in Secret Manager (for third-party connectors only)

> Skip this step if you are only using Google Workspace connectors (Gmail, Calendar, Drive).

Create the OAuth credentials your connectors need. The secret names must match what you put in the `secrets` map in `terraform.tfvars`.

```bash
# Jira example
echo -n "your-jira-client-id"     | gcloud secrets create MY_JIRA_CLIENT_ID     --project=YOUR_PROJECT_ID --data-file=-
echo -n "your-jira-client-secret" | gcloud secrets create MY_JIRA_CLIENT_SECRET  --project=YOUR_PROJECT_ID --data-file=-
echo -n "your-jira-refresh-token" | gcloud secrets create MY_JIRA_REFRESH_TOKEN  --project=YOUR_PROJECT_ID --data-file=-

# Confluence example
echo -n "your-conf-client-id"     | gcloud secrets create MY_CONF_CLIENT_ID     --project=YOUR_PROJECT_ID --data-file=-
echo -n "your-conf-client-secret" | gcloud secrets create MY_CONF_CLIENT_SECRET  --project=YOUR_PROJECT_ID --data-file=-
echo -n "your-conf-refresh-token" | gcloud secrets create MY_CONF_REFRESH_TOKEN  --project=YOUR_PROJECT_ID --data-file=-

# Salesforce example
echo -n "your-sf-client-id"       | gcloud secrets create MY_SF_CLIENT_ID       --project=YOUR_PROJECT_ID --data-file=-
echo -n "your-sf-client-secret"   | gcloud secrets create MY_SF_CLIENT_SECRET    --project=YOUR_PROJECT_ID --data-file=-
```

### Step 5 — Deploy

```bash
terraform init
terraform plan     # Review what will be created
terraform apply    # Deploy
```

After apply, Terraform prints URLs and IDs you can use to access your Gemini Enterprise instance.

---

## Step-by-Step Configuration Guide

All configuration lives in `terraform.tfvars`. Below is a complete guide for each section.

### Basic Settings

```hcl
# The only mandatory field
project_id = "your-gcp-project-id"

# Search engine settings
discovery_engine_location  = "global"                  # global | us | eu
search_engine_id           = "my-gemini-enterprise"    # lowercase letters, numbers, hyphens only
search_engine_display_name = "My Gemini Enterprise"
app_type                   = "APP_TYPE_INTRANET"       # APP_TYPE_INTRANET | APP_TYPE_INTERNET
search_tier                = "SEARCH_TIER_ENTERPRISE"
search_add_ons             = ["SEARCH_ADD_ON_LLM"]
```

---

### Third-Party Connectors (Jira, Confluence, Salesforce)

These connectors authenticate via OAuth credentials stored in GCP Secret Manager.

| Connector | `data_source` value | Auth Flow | Secrets Needed |
|-----------|---------------------|-----------|----------------|
| Jira Cloud | `jira` | 3-legged OAuth | `client_id`, `client_secret`, `refresh_token` |
| Confluence Cloud | `confluence` | 3-legged OAuth | `client_id`, `client_secret`, `refresh_token` |
| Salesforce | `salesforce` | 2-legged OAuth | `client_id`, `client_secret` |

All third-party connectors share the same structure in `terraform.tfvars`:

```hcl
third_party_connectors = {

  # Each key is a unique name you choose for this connector instance
  jira = {
    enabled                      = true               # Set false to skip without deleting config
    data_source                  = "jira"             # The connector type
    collection_id                = "jira-collection"  # Unique ID for this collection
    collection_display_name      = "Jira"

    # Non-secret connection parameters
    params = {
      instance_uri = "https://your-org.atlassian.net"
      instance_id  = "your-cloud-id-uuid"  # From: https://your-org.atlassian.net/_edge/tenant_info
    }

    # Secret Manager secret IDs (the names of your secrets in GCP)
    secrets = {
      client_id     = "MY_JIRA_CLIENT_ID"      # Name this anything you want
      client_secret = "MY_JIRA_CLIENT_SECRET"
      refresh_token = "MY_JIRA_REFRESH_TOKEN"
    }

    refresh_interval             = "86400s"   # Full re-sync: every 24 hours
    incremental_refresh_interval = "21600s"   # Incremental sync: every 6 hours

    entities = [
      { entity_name = "issue" },
      { entity_name = "project" },
      { entity_name = "comment" },
      { entity_name = "attachment" }
    ]

    connector_modes = ["FEDERATED"]   # FEDERATED | DATA_INGESTION
    sync_mode       = "PERIODIC"      # PERIODIC | MANUAL
  }

  # Add more connectors below using the same structure
  confluence = {
    enabled     = false    # Currently disabled — config preserved for future use
    data_source = "confluence"
    # ... rest of config
  }
}
```

**How to enable/disable a connector without losing its config:**

```hcl
jira = {
  enabled = false   # Just flip this flag — all other settings are preserved
  ...
}
```

**How to add a second instance of the same connector type** (e.g., two Jira clouds):

```hcl
third_party_connectors = {
  jira_us = {
    data_source = "jira"
    params      = { instance_uri = "https://us-org.atlassian.net", instance_id = "uuid-1" }
    secrets     = { client_id = "JIRA_US_CLIENT_ID", ... }
    ...
  }
  jira_eu = {
    data_source = "jira"
    params      = { instance_uri = "https://eu-org.atlassian.net", instance_id = "uuid-2" }
    secrets     = { client_id = "JIRA_EU_CLIENT_ID", ... }
    ...
  }
}
```

---

### Google Workspace Connectors (Gmail, Calendar, Drive)

These connectors use your GCP project's Google Workspace identity — **no OAuth secrets or Secret Manager setup required**.

| Connector | `data_source` value | `entity_name` value |
|-----------|---------------------|---------------------|
| Gmail | `google_mail` | `google_mail` |
| Google Calendar | `google_calendar` | `google_calendar` |
| Google Drive | `google_drive` | `google_drive` |

```hcl
workspace_connectors = {

  gmail = {
    enabled                 = true
    data_source             = "google_mail"
    collection_id           = "mail-collection"
    collection_display_name = "Gmail"
    refresh_interval        = "3600s"           # Sync every hour
    entity                  = { entity_name = "google_mail" }
    connector_modes         = ["FEDERATED"]
  }

  calendar = {
    enabled                 = true
    data_source             = "google_calendar"
    collection_id           = "calendar-collection"
    collection_display_name = "Google Calendar"
    refresh_interval        = "3600s"
    entity                  = { entity_name = "google_calendar" }
    connector_modes         = ["FEDERATED"]
  }

  drive = {
    enabled                 = true
    data_source             = "google_drive"
    collection_id           = "drive-collection"
    collection_display_name = "Google Drive"
    refresh_interval        = "3600s"
    entity                  = { entity_name = "google_drive" }
    connector_modes         = ["FEDERATED"]
  }
}
```

---

### Widget Configuration

The search widget is an embeddable UI component for end users.

```hcl
enable_widget_config           = true
widget_config_id               = "default_search_widget_config"
widget_enable_web_app          = true
widget_allow_public_access     = false          # Set true only for public-facing deployments
widget_allowlisted_domains     = ["example.com"]

# Interaction mode
widget_interaction_type        = "SEARCH_WITH_ANSWER"
# Options:
#   SEARCH_ONLY           — shows search results only
#   SEARCH_WITH_ANSWER    — shows AI-generated answers above results
#   SEARCH_WITH_FOLLOW_UPS — conversational mode with follow-up questions

widget_enable_autocomplete     = true
widget_enable_quality_feedback = true
widget_enable_safe_search      = true

# Optional: custom branding logo (must be a publicly accessible URL)
widget_logo_url = "https://example.com/logo.svg"

# Optional: homepage shortcut links
widget_homepage_shortcuts = [
  {
    title           = "HR Portal"
    destination_uri = "https://hr.example.com"
  },
  {
    title           = "Support Docs"
    destination_uri = "https://docs.example.com"
  }
]
```

---

### License Configuration

By default, `enable_license_config = false` so you can test the deployment without triggering a license purchase. Enable it when you are ready to activate Gemini Enterprise.

```hcl
enable_license_config = true           # Set true to create/manage the license
license_count         = 25             # Number of user seats
free_trial            = true           # Set false for paid subscription
subscription_tier     = "SUBSCRIPTION_TIER_ENTERPRISE"
subscription_term     = "SUBSCRIPTION_TERM_ONE_MONTH"

start_date = { year = 2025, month = 1, day = 1 }
end_date   = { year = 2025, month = 12, day = 31 }
```

| `subscription_tier` values | Description |
|---------------------------|-------------|
| `SUBSCRIPTION_TIER_STANDARD` | Standard tier |
| `SUBSCRIPTION_TIER_ENTERPRISE` | Enterprise tier (recommended) |

| `subscription_term` values | Description |
|---------------------------|-------------|
| `SUBSCRIPTION_TERM_ONE_MONTH` | Monthly |
| `SUBSCRIPTION_TERM_ONE_YEAR` | Annual |
| `SUBSCRIPTION_TERM_THREE_YEARS` | 3-year |

---

## Multi-Environment Deployment

Use the `environments/` directory to manage separate configs for dev, staging, and production.

```bash
# Plan for dev (no license, fewer connectors)
terraform plan -var-file="environments/dev.tfvars"

# Apply for production (full license, all connectors active)
terraform apply -var-file="environments/prod.tfvars"
```

Start from the provided examples:

```bash
cp environments/dev.tfvars.example   environments/dev.tfvars
cp environments/prod.tfvars.example  environments/prod.tfvars
```

Edit each file with environment-specific values. Both files share the same codebase — only the config changes.

---

## Valid Entity Names

### Jira Cloud
| Entity | What it syncs |
|--------|--------------|
| `issue` | All Jira issues |
| `project` | Jira projects |
| `comment` | Issue comments |
| `attachment` | File attachments |
| `worklog` | Work logs |
| `bug`, `epic`, `story`, `task` | Issue type aliases |
| `board` | Jira boards |

### Confluence Cloud
| Entity | What it syncs |
|--------|--------------|
| `page` | Wiki pages |
| `space` | Confluence spaces |
| `blog` | Blog posts |
| `attachment` | File attachments |
| `comment` | Comments |
| `whiteboard` | Whiteboards |

### Salesforce
| Entity | What it syncs |
|--------|--------------|
| `account` | Company accounts |
| `case` | Support cases |
| `contact` | Contacts |
| `contentdocument` | Files and documents |
| `lead` | Leads |
| `opportunity` | Opportunities |
| `task` | Tasks |

### Google Workspace
| Connector | Entity name |
|-----------|-------------|
| Gmail | `google_mail` |
| Calendar | `google_calendar` |
| Drive | `google_drive` |

---

## GCP APIs to Enable

Run this once before your first `terraform apply`:

```bash
gcloud services enable \
  discoveryengine.googleapis.com \
  secretmanager.googleapis.com \
  --project=YOUR_PROJECT_ID
```

For Google Workspace connectors, also ensure your GCP project is linked to a Google Workspace domain.

---

## Remote State Backend

For team deployments, store Terraform state in GCS instead of locally. Uncomment and configure the backend block in `versions.tf`:

```hcl
terraform {
  backend "gcs" {
    bucket = "your-terraform-state-bucket"
    prefix = "gemini-enterprise/production"
  }
}
```

Then run `terraform init` again to migrate state.

---

## Outputs

After `terraform apply`, these values are printed:

| Output | Description |
|--------|-------------|
| `search_engine_id` | The ID of the Discovery Engine search engine |
| `search_engine_display_name` | The display name of the search engine |
| `gemini_enterprise_console_url` | Direct URL to the Gemini Enterprise console |
| `discovery_engine_console_url` | URL to the Discovery Engine console |
| `vertex_ai_search_url` | URL to the Vertex AI Search webapp |
| `third_party_connector_names` | Map of created third-party connector resource names |
| `third_party_connector_states` | Map of third-party connector sync states |
| `workspace_connector_names` | Map of created workspace connector resource names |
| `workspace_connector_states` | Map of workspace connector sync states |
| `linked_data_store_ids` | All data store IDs linked to the search engine |
| `widget_config_id` | The widget configuration ID |
| `license_config_id` | The license configuration ID (when enabled) |

---

## Troubleshooting

### `Error: google_secret_manager_secret: Not found`

The secret name in your `secrets` map does not match an existing secret in Secret Manager.

**Fix:** Check the exact secret name in the GCP Console → Secret Manager and update your `terraform.tfvars` to match.

```bash
# List all secrets in your project
gcloud secrets list --project=YOUR_PROJECT_ID
```

### `Error 403: Discovery Engine API has not been enabled`

The Discovery Engine API is not enabled in your project.

**Fix:**
```bash
gcloud services enable discoveryengine.googleapis.com --project=YOUR_PROJECT_ID
```

### `Error: Data store not found during engine creation`

A connector failed to create its data stores — usually because OAuth credentials are invalid or expired.

**Fix:**
1. Verify the connector credentials by testing them in the respective platform's developer console
2. Re-create the secrets in Secret Manager with fresh values
3. Re-run `terraform apply`

### `lifecycle { ignore_changes = all }` — why is my connector not updating?

Third-party connectors use `lifecycle { ignore_changes = all }` to prevent Terraform from overwriting credentials and sync settings that GCP manages internally after first creation. This is intentional.

To force an update, you must `terraform destroy` the specific connector and re-apply:

```bash
terraform destroy -target='module.gemini_enterprise.google_discovery_engine_data_connector.third_party["jira"]'
terraform apply
```

### Connector shows `FAILED` state in the console

This usually means the OAuth refresh token has expired.

**Fix:** Generate a new refresh token in the Atlassian or Salesforce developer console, update the secret in Secret Manager, and re-create the connector (see above).

---

## Requirements

| Tool | Version |
|------|---------|
| Terraform | >= 1.7.0 |
| google provider | >= 6.0, < 8.0 |
| google-beta provider | >= 6.0, < 8.0 |
| Google Cloud SDK | Latest |

---

## License

See [LICENSE.txt](../LICENSE.txt) for details.

---

*For details on what changed compared to the Oanda reference implementation, see [ENHANCEMENTS.md](../ENHANCEMENTS.md).*

