# Gemini Enterprise Terraform Deployment

This Terraform project deploys Google Gemini Enterprise with Discovery Engine resources for enterprise search and conversational AI capabilities, with support for multiple data connectors.

## Features

- **Discovery Engine License Configuration** - Manage Gemini Enterprise licenses
- **Search Engine** - Enterprise search with LLM-powered capabilities
- **Widget Configuration** - Customize the search widget UI with branding, logo, and interaction settings
- **Data Connectors** - Integrate multiple data sources for enterprise search:
  - **Jira Cloud** - Sync Jira issues, projects, comments, and other entities
  - **Confluence Cloud** - Sync Confluence pages, spaces, blogs, and other content
  - **Google Workspace** - Gmail, Calendar, and Drive integration (federated search)
  - **Salesforce** - Sync leads, opportunities, accounts, and other CRM data

## Prerequisites

- Terraform >= 1.5.0
- Google Cloud SDK installed and configured
- GCP Project with billing enabled
- Gemini Enterprise license/subscription
- Sufficient IAM permissions (Owner or Editor role recommended for initial setup)

## Quick Start

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your project details

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Module Configuration

### Basic Usage

```hcl
module "gemini_enterprise" {
  source = "./modules/gemini-enterprise"

  project_id = "your-project-id"
  engine_id  = "your-search-engine"
  location   = "global"

  # License configuration
  enable_license_config = true
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
  app_type       = "APP_TYPE_INTRANET"
  search_tier    = "SEARCH_TIER_ENTERPRISE"
  search_add_ons = ["SEARCH_ADD_ON_LLM"]
}
```

### Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `project_id` | GCP Project ID | string | required |
| `engine_id` | Search engine ID | string | required |
| `location` | Discovery Engine location (global, us, eu) | string | `"global"` |
| `enable_license_config` | Enable license configuration | bool | `true` |
| `license_count` | Number of licenses | number | `25` |
| `free_trial` | Whether this is a free trial | bool | `true` |
| `subscription_tier` | Subscription tier | string | `"SUBSCRIPTION_TIER_ENTERPRISE"` |
| `subscription_term` | Subscription term | string | `"SUBSCRIPTION_TERM_ONE_MONTH"` |
| `start_date` | License start date (year, month, day) | object | required |
| `end_date` | License end date (year, month, day) | object | required |
| `engine_display_name` | Display name for the search engine | string | `null` (uses engine_id) |
| `collection_id` | Collection ID for search engine and connectors | string | `"default_collection"` |
| `collection_display_name` | Display name for the collection | string | `"Default Collection"` |
| `data_store_ids` | List of data store IDs to associate | list(string) | `[]` |
| `app_type` | Application type for the search engine | string | `"APP_TYPE_INTRANET"` |
| `search_tier` | Search tier for the engine | string | `"SEARCH_TIER_ENTERPRISE"` |
| `search_add_ons` | List of search add-ons to enable | list(string) | `["SEARCH_ADD_ON_LLM"]` |

## Widget Configuration

The module creates a widget configuration that customizes the search widget UI, including branding, logo, and interaction settings.

### Widget Configuration Example

```hcl
module "gemini_enterprise" {
  source = "./modules/gemini-enterprise"

  project_id = "your-project-id"
  engine_id  = "your-search-engine"
  location   = "global"

  # ... other configuration ...

  # Widget configuration
  enable_widget_config       = true
  widget_enable_web_app      = true
  widget_allow_public_access = false
  widget_interaction_type    = "SEARCH_WITH_ANSWER"
  widget_enable_autocomplete = true

  # Custom branding with logo
  widget_logo_url = "https://your-domain.com/logo.png"

  # Homepage shortcuts
  widget_homepage_shortcuts = [
    {
      title           = "Documentation"
      destination_uri = "https://docs.your-domain.com"
    },
    {
      title           = "Support"
      destination_uri = "https://support.your-domain.com"
    }
  ]
}
```

### Widget Configuration Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `enable_widget_config` | Enable widget configuration | bool | `true` |
| `widget_config_id` | Widget configuration ID | string | `"default_search_widget_config"` |
| `widget_enable_web_app` | Enable web app for the widget | bool | `true` |
| `widget_allow_public_access` | Allow public access to widget | bool | `false` |
| `widget_allowlisted_domains` | Domains allowed to embed widget | list(string) | `[]` |
| `widget_interaction_type` | Search interaction type | string | `"SEARCH_WITH_ANSWER"` |
| `widget_enable_autocomplete` | Enable autocomplete | bool | `true` |
| `widget_enable_quality_feedback` | Enable quality feedback | bool | `true` |
| `widget_enable_safe_search` | Enable safe search | bool | `true` |
| `widget_logo_url` | URL of logo image for branding | string | `null` |
| `widget_homepage_shortcuts` | Homepage shortcuts | list(object) | `[]` |

### Interaction Types

| Type | Description |
|------|-------------|
| `SEARCH_ONLY` | Basic search without AI-generated answers |
| `SEARCH_WITH_ANSWER` | Search with AI-generated answer summaries |
| `SEARCH_WITH_FOLLOW_UPS` | Search with answers and follow-up question suggestions |

## Jira Cloud Data Connector

The module supports integrating Jira Cloud as a data source for enterprise search. This allows users to search across Jira issues, projects, and other entities directly from the Gemini Enterprise search interface.

### Prerequisites for Jira Integration

1. **Jira Cloud Instance** - You need an Atlassian Jira Cloud instance
2. **OAuth 2.0 App** - Create an OAuth 2.0 app in your Atlassian Developer Console
3. **Secret Manager Secrets** - Store OAuth credentials in Google Secret Manager

### Setting Up Jira OAuth Credentials

1. Go to [Atlassian Developer Console](https://developer.atlassian.com/console/myapps/)
2. Create a new OAuth 2.0 integration
3. Configure the OAuth 2.0 (3LO) settings:
   - **Callback URL**: `https://vertexaisearch.cloud.google.com/oauth-redirect`
   - **Scopes**: Add the following permissions:
     - `read:jira-work`
     - `manage:jira-project`
     - `read:jira-user`
     - `read:audit-log:jira`
     - `read:avatar:jira`
     - `read:group:jira`
     - `read:issue-details:jira`
     - `read:issue-security-scheme:jira`
     - `read:issue-security-level:jira`
     - `read:user:jira`
     - `read:project:jira`
     - `read:jql:jira`
     - `read:board-scope.admin:jira-software`
     - `read:board-scope:jira-software`

### Generating the OAuth Refresh Token

After creating your OAuth 2.0 app, you need to generate a refresh token:

#### Step 1: Get the Authorization Code

Replace `YOUR_CLIENT_ID` with your actual client ID in this URL and open it in your browser:

```
https://auth.atlassian.com/authorize?audience=api.atlassian.com&client_id=YOUR_CLIENT_ID&scope=read%3Ajira-work%20manage%3Ajira-project%20read%3Ajira-user%20read%3Aaudit-log%3Ajira%20read%3Aavatar%3Ajira%20read%3Agroup%3Ajira%20read%3Aissue-details%3Ajira%20read%3Aissue-security-scheme%3Ajira%20read%3Aissue-security-level%3Ajira%20read%3Auser%3Ajira%20read%3Aproject%3Ajira%20read%3Ajql%3Ajira%20read%3Aboard-scope.admin%3Ajira-software%20read%3Aboard-scope%3Ajira-software%20offline_access&redirect_uri=https%3A%2F%2Fvertexaisearch.cloud.google.com%2Foauth-redirect&state=12345&response_type=code&prompt=consent
```

#### Step 2: Authorize the Application

- Select your Atlassian site
- Click "Accept" to grant permissions
- You'll be redirected to a URL containing the authorization code

#### Step 3: Extract the Code from URL

After redirection, copy the `code` parameter from the URL. It will look like:

```
https://vertexaisearch.cloud.google.com/console/oauth/jira_oauth.html?state=12345&code=YOUR_CODE_HERE
```

**Important**: The authorization code expires after **1 minute**. You must complete the next step quickly.

#### Step 4: Exchange Code for Refresh Token

Run this curl command immediately, replacing `YOUR_CLIENT_ID`, `YOUR_CLIENT_SECRET`, and `YOUR_CODE`:

```bash
curl --request POST \
  --url 'https://auth.atlassian.com/oauth/token' \
  --header 'Content-Type: application/json' \
  --data '{
    "grant_type": "authorization_code",
    "client_id": "YOUR_CLIENT_ID",
    "client_secret": "YOUR_CLIENT_SECRET",
    "code": "YOUR_CODE",
    "redirect_uri": "https://vertexaisearch.cloud.google.com/oauth-redirect"
  }'

```

#### Step 5: Save the Refresh Token

The response will include a `refresh_token`. Save this value - you'll need it for Secret Manager in the next step.

Example response:
```json
{
  "access_token": "...",
  "expires_in": 3600,
  "refresh_token": "YOUR_REFRESH_TOKEN_HERE",
  "scope": "read:jira-work manage:jira-project ...",
  "token_type": "Bearer"
}
```

### Secret Manager Setup

The module reads Jira OAuth credentials from Secret Manager. Create the following secrets with these exact names:

```bash
# Create secrets in Secret Manager
echo -n "your-client-id" | gcloud secrets create ONIX_JIRA_INTEGRATION_CLIENTID --data-file=-
echo -n "your-client-secret" | gcloud secrets create ONIX_JIRA_INTEGRATION_SECRET --data-file=-
echo -n "your-refresh-token" | gcloud secrets create ONIX_JIRA_INTEGRATION_REFRESH_TOKEN --data-file=-
```

### Enabling Jira Connector

```hcl
module "gemini_enterprise" {
  source = "./modules/gemini-enterprise"

  project_id = "your-project-id"
  engine_id  = "your-search-engine"
  location   = "global"

  # ... other configuration ...

  # Jira Cloud Connector
  enable_jira_connector = true
  jira_instance_id      = "your-domain"  # From https://your-domain.atlassian.net
  jira_instance_uri     = "https://your-domain.atlassian.net"

  # Sync configuration
  jira_refresh_interval             = "86400s"   # Full sync daily
  jira_incremental_refresh_interval = "21600s"   # Incremental sync every 6 hours

  # Entities to sync
  jira_entities = [
    { entity_name = "issue" },
    { entity_name = "project" },
    { entity_name = "comment" }
  ]

  # Optional settings
  jira_static_ip_enabled = false
  jira_connector_modes   = ["DATA_INGESTION"]
  jira_sync_mode         = "PERIODIC"
}
```

### Jira Connector Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `enable_jira_connector` | Enable Jira Cloud connector | bool | `false` |
| `jira_instance_id` | Jira instance ID (subdomain) | string | `""` |
| `jira_instance_uri` | Full Jira instance URL | string | `""` |
| `jira_refresh_interval` | Full refresh interval | string | `"86400s"` |
| `jira_incremental_refresh_interval` | Incremental refresh interval | string | `"21600s"` |
| `jira_entities` | List of entities to sync | list(object) | `[{entity_name = "issue"}]` |
| `jira_static_ip_enabled` | Use static IP for connector | bool | `false` |
| `jira_connector_modes` | Connector modes | list(string) | `["DATA_INGESTION"]` |
| `jira_sync_mode` | Sync mode (PERIODIC, MANUAL) | string | `"PERIODIC"` |

### Supported Jira Entity Types

| Entity | Description |
|--------|-------------|
| `issue` | Jira issues (bugs, tasks, stories, etc.) |
| `project` | Jira projects |
| `comment` | Issue comments |
| `attachment` | Issue attachments |
| `bug` | Bug issue type |
| `epic` | Epic issue type |
| `story` | Story issue type |
| `task` | Task issue type |
| `worklog` | Work logs |
| `board` | Jira boards |

### How Data Stores Work

When you enable the Jira connector:

1. The connector creates data stores in `default_collection`
2. Each entity type creates a separate data store with naming pattern: `{collection_id}_{entity_name}`
3. The search engine automatically links to these data stores
4. Data syncs according to your configured intervals

## Confluence Cloud Data Connector

The module supports integrating Confluence Cloud as a data source for enterprise search. This allows users to search across Confluence pages, spaces, blogs, and other content directly from the Gemini Enterprise search interface.

### Prerequisites for Confluence Integration

1. **Confluence Cloud Instance** - You need an Atlassian Confluence Cloud instance
2. **OAuth 2.0 App** - Create an OAuth 2.0 app in your Atlassian Developer Console (can use the same app as Jira if both are in the same Atlassian workspace)
3. **Secret Manager Secrets** - Store OAuth credentials in Google Secret Manager

### Setting Up Confluence OAuth Credentials

1. Go to [Atlassian Developer Console](https://developer.atlassian.com/console/myapps/)
2. Create a new OAuth 2.0 integration
3. Configure the OAuth 2.0 (3LO) settings:
   - **Callback URL**: `https://vertexaisearch.cloud.google.com/oauth-redirect`
   - **Scopes**: Add the following permissions:
     - `read:content-details:confluence`
     - `read:attachment:confluence`
     - `read:group:confluence`
     - `read:user:confluence`
     - `read:configuration:confluence`
     - `read:space:confluence`
     - `read:content.metadata:confluence`
     - `read:whiteboard:confluence`
     - `read:page:confluence`
     - `read:comment:confluence`
     - `search:confluence`

### Generating the OAuth Refresh Token

After creating your OAuth 2.0 app, you need to generate a refresh token:

#### Step 1: Get the Authorization Code

Replace `YOUR_CLIENT_ID` with your actual client ID in this URL and open it in your browser:

```
https://auth.atlassian.com/authorize?audience=api.atlassian.com&client_id=YOUR_CLIENT_ID&scope=read%3Acontent-details%3Aconfluence%20read%3Aattachment%3Aconfluence%20read%3Agroup%3Aconfluence%20read%3Auser%3Aconfluence%20read%3Aconfiguration%3Aconfluence%20read%3Aspace%3Aconfluence%20read%3Acontent.metadata%3Aconfluence%20read%3Awhiteboard%3Aconfluence%20read%3Apage%3Aconfluence%20read%3Acomment%3Aconfluence%20search%3Aconfluence%20offline_access&redirect_uri=https%3A%2F%2Fvertexaisearch.cloud.google.com%2Foauth-redirect&state=12345&response_type=code&prompt=consent
```

#### Step 2: Authorize the Application

- Select your Atlassian site
- Click "Accept" to grant permissions
- You'll be redirected to a URL containing the authorization code

#### Step 3: Extract the Code from URL

After redirection, copy the `code` parameter from the URL. It will look like:

```
https://vertexaisearch.cloud.google.com/console/oauth/confluence_oauth.html?state=12345&code=YOUR_CODE_HERE
```

**Important**: The authorization code expires after **1 minute**. You must complete the next step quickly.

#### Step 4: Exchange Code for Refresh Token

Run this curl command immediately, replacing `YOUR_CLIENT_ID`, `YOUR_CLIENT_SECRET`, and `YOUR_CODE`:

```bash
curl --request POST \
  --url 'https://auth.atlassian.com/oauth/token' \
  --header 'Content-Type: application/json' \
  --data '{
    "grant_type": "authorization_code",
    "client_id": "YOUR_CLIENT_ID",
    "client_secret": "YOUR_CLIENT_SECRET",
    "code": "YOUR_CODE_FROM_URL",
    "redirect_uri": "https://vertexaisearch.cloud.google.com/oauth-redirect"
  }'
```

#### Step 5: Save the Refresh Token

The response will include a `refresh_token`. Save this value - you'll need it for Secret Manager in the next step.

Example response:
```json
{
  "access_token": "...",
  "expires_in": 3600,
  "refresh_token": "YOUR_REFRESH_TOKEN_HERE",
  "scope": "read:content-details:confluence read:attachment:confluence ...",
  "token_type": "Bearer"
}
```

### Secret Manager Setup for Confluence

The module reads Confluence OAuth credentials from Secret Manager. Create the following secrets with these exact names:

```bash
# Create secrets in Secret Manager
echo -n "your-client-id" | gcloud secrets create ONIX_CONFLUENCE_INTEGRATION_CLIENTID --data-file=-
echo -n "your-client-secret" | gcloud secrets create ONIX_CONFLUENCE_INTEGRATION_SECRET --data-file=-
echo -n "your-refresh-token" | gcloud secrets create ONIX_CONFLUENCE_INTEGRATION_REFRESH_TOKEN --data-file=-
```



### Enabling Confluence Connector

```hcl
module "gemini_enterprise" {
  source = "./modules/gemini-enterprise"

  project_id = "your-project-id"
  engine_id  = "your-search-engine"
  location   = "global"

  # ... other configuration ...

  # Confluence Cloud Connector
  enable_confluence_connector = true
  confluence_instance_id      = "your-cloud-id"  # Get from https://your-domain.atlassian.net/_edge/tenant_info
  confluence_instance_uri     = "https://your-domain.atlassian.net"
  confluence_collection_id    = "my-confluence-collection"
  confluence_collection_display_name = "Confluence Collection"

  # Sync configuration
  confluence_refresh_interval             = "86400s"   # Full sync daily
  confluence_incremental_refresh_interval = "21600s"   # Incremental sync every 6 hours

  # Entities to sync
  confluence_entities = [
    { entity_name = "page" },
    { entity_name = "space" },
    { entity_name = "blog" },
    { entity_name = "attachment" },
    { entity_name = "comment" }
  ]

  # Optional settings
  confluence_static_ip_enabled = false
  confluence_connector_modes   = ["DATA_INGESTION"]
  confluence_sync_mode         = "PERIODIC"
}
```

### Confluence Connector Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `enable_confluence_connector` | Enable Confluence Cloud connector | bool | `false` |
| `confluence_instance_id` | Confluence Cloud ID (UUID from tenant_info) | string | `""` |
| `confluence_instance_uri` | Full Confluence instance URL | string | `""` |
| `confluence_collection_id` | Collection ID for Confluence | string | `"confluence_default_collection"` |
| `confluence_collection_display_name` | Display name for collection | string | `"Default collection for Confluence"` |
| `confluence_refresh_interval` | Full refresh interval | string | `"86400s"` |
| `confluence_incremental_refresh_interval` | Incremental refresh interval | string | `"21600s"` |
| `confluence_entities` | List of entities to sync | list(object) | `[{entity_name = "page"}]` |
| `confluence_static_ip_enabled` | Use static IP for connector | bool | `false` |
| `confluence_static_ip_enabled` | Use static IP for connector | bool | `false` |
| `confluence_connector_modes` | Connector modes | list(string) | `["DATA_INGESTION"]` |
| `confluence_sync_mode` | Sync mode (PERIODIC, MANUAL) | string | `"PERIODIC"` |
### Supported Confluence Entity Types

| Entity | Description |
|--------|-------------|
| `page` | Confluence pages |
| `space` | Confluence spaces |
| `blog` | Blog posts |
| `attachment` | Page attachments |
| `comment` | Page comments |
| `whiteboard` | Confluence whiteboards |

## Google Workspace Connectors

The module supports Google Workspace integration for Gmail, Calendar, and Drive. These connectors use federated search mode, meaning data stays in Google Workspace and is searched in real-time.

### Enabling Google Workspace Connectors

```hcl
module "gemini_enterprise" {
  source = "./modules/gemini-enterprise"

  project_id = "your-project-id"
  engine_id  = "your-search-engine"
  location   = "global"

  # ... other configuration ...

  # Gmail Connector
  enable_mail_connector        = true
  mail_collection_id           = "my-mail-collection"
  mail_collection_display_name = "Gmail Collection"
  mail_refresh_interval        = "3600s"
  mail_entity = {
    entity_name = "google_mail"
    params      = null
  }

  # Calendar Connector
  enable_calendar_connector        = true
  calendar_collection_id           = "my-calendar-collection"
  calendar_collection_display_name = "Calendar Collection"
  calendar_refresh_interval        = "3600s"
  calendar_entity = {
    entity_name = "google_calendar"
    params      = null
  }

  # Drive Connector
  enable_drive_connector        = true
  drive_collection_id           = "my-drive-collection"
  drive_collection_display_name = "Drive Collection"
  drive_refresh_interval        = "3600s"
  drive_entity = {
    entity_name = "google_drive"
    params      = null
  }

  # Connector mode for all workspace connectors
  workspace_connector_modes = ["FEDERATED"]
}
```

### Gmail Connector Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `enable_mail_connector` | Enable Gmail connector | bool | `false` |
| `mail_collection_id` | Collection ID for mail | string | `"default_collection"` |
| `mail_collection_display_name` | Display name for collection | string | `"Default collection for mail"` |
| `mail_refresh_interval` | Refresh interval | string | `"86400s"` |
| `mail_static_ip_enabled` | Use static IP | bool | `false` |
| `mail_auto_run_disabled` | Disable auto sync | bool | `false` |
| `mail_entity` | Entity configuration | object | `{entity_name = "google_mail"}` |

### Calendar Connector Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `enable_calendar_connector` | Enable Calendar connector | bool | `false` |
| `calendar_collection_id` | Collection ID for calendar | string | `"default_collection"` |
| `calendar_collection_display_name` | Display name for collection | string | `"Default collection for calendar"` |
| `calendar_refresh_interval` | Refresh interval | string | `"86400s"` |
| `calendar_static_ip_enabled` | Use static IP | bool | `false` |
| `calendar_auto_run_disabled` | Disable auto sync | bool | `false` |
| `calendar_entity` | Entity configuration | object | `{entity_name = "google_calendar"}` |

### Drive Connector Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `enable_drive_connector` | Enable Drive connector | bool | `false` |
| `drive_collection_id` | Collection ID for drive | string | `"default_collection"` |
| `drive_collection_display_name` | Display name for collection | string | `"Default collection for drive"` |
| `drive_refresh_interval` | Refresh interval | string | `"86400s"` |
| `drive_static_ip_enabled` | Use static IP | bool | `false` |
| `drive_auto_run_disabled` | Disable auto sync | bool | `false` |
| `drive_entity` | Entity configuration | object | `{entity_name = "google_drive"}` |
| `workspace_connector_modes` | Connector modes | list(string) | `["FEDERATED"]` |

## Salesforce Data Connector

The module supports Salesforce integration for syncing CRM data such as leads, opportunities, accounts, and more.

### Prerequisites for Salesforce Integration

1. **Salesforce Instance** - You need a Salesforce instance
2. **OAuth 2.0 Connected App** - Create a Connected App in Salesforce Setup
3. **Secret Manager Secrets** - Store OAuth credentials in Google Secret Manager

### Secret Manager Setup for Salesforce

Create the following secrets with these exact names:

```bash
echo -n "your-client-id" | gcloud secrets create ONIX_SALESFORCE_ZOWIE_KEY --data-file=-
echo -n "your-client-secret" | gcloud secrets create ONIX_SALESFORCE_ZOWIE_SECRET --data-file=-
```

### Enabling Salesforce Connector

```hcl
module "gemini_enterprise" {
  source = "./modules/gemini-enterprise"

  project_id = "your-project-id"
  engine_id  = "your-search-engine"
  location   = "global"

  # ... other configuration ...

  # Salesforce Connector
  enable_salesforce_connector             = true
  salesforce_collection_id                = "my-salesforce-collection"
  salesforce_collection_display_name      = "Salesforce Collection"
  salesforce_instance_url                 = "https://your-instance.my.salesforce.com"
  salesforce_refresh_interval             = "86400s"
  salesforce_incremental_refresh_interval = "10800s"

  # Entities to sync
  salesforce_entities = [
    { entity_name = "lead" },
    { entity_name = "opportunity" },
    { entity_name = "account" },
    { entity_name = "contact" }
  ]

  salesforce_connector_modes = ["DATA_INGESTION"]
  salesforce_sync_mode       = "PERIODIC"
}
```

### Salesforce Connector Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `enable_salesforce_connector` | Enable Salesforce connector | bool | `false` |
| `salesforce_collection_id` | Collection ID | string | `"default_collection"` |
| `salesforce_collection_display_name` | Display name | string | `"Default collection for salesforce"` |
| `salesforce_instance_url` | Salesforce instance URL | string | `"https://login.salesforce.com"` |
| `salesforce_refresh_interval` | Full refresh interval | string | `"86400s"` |
| `salesforce_incremental_refresh_interval` | Incremental refresh interval | string | `"10800s"` |
| `salesforce_entities` | List of entities to sync | list(object) | `[{entity_name = "account"}]` |
| `salesforce_static_ip_enabled` | Use static IP | bool | `false` |
| `salesforce_auto_run_disabled` | Disable auto sync | bool | `false` |
| `salesforce_connector_modes` | Connector modes | list(string) | `["DATA_INGESTION"]` |
| `salesforce_sync_mode` | Sync mode | string | `"PERIODIC"` |

### Supported Salesforce Entity Types

| Entity | Description |
|--------|-------------|
| `lead` | Sales leads |
| `opportunity` | Sales opportunities |
| `contact` | Contacts |
| `account` | Accounts |
| `case` | Support cases |
| `contract` | Contracts |
| `campaign` | Marketing campaigns |

## Outputs

### License Configuration Outputs

| Output | Description |
|--------|-------------|
| `license_config_id` | License configuration ID |
| `license_config_name` | Full license configuration resource name |
| `license_count` | Number of licenses provisioned |
| `subscription_tier` | Subscription tier of the license |

### Search Engine Outputs

| Output | Description |
|--------|-------------|
| `engine_id` | Search engine ID |
| `engine_name` | Full search engine resource name |
| `engine_display_name` | Display name of the search engine |
| `engine_location` | Location of the search engine |
| `engine_collection_id` | Collection ID of the search engine |
| `engine_full_id` | Full resource ID (contains cid for Vertex AI Search URL) |
| `app_type` | Application type of the search engine |
| `search_tier` | Search tier configured for the engine |
| `search_add_ons` | Search add-ons enabled for the engine |

### Jira Connector Outputs

| Output | Description |
|--------|-------------|
| `jira_connector_name` | Full Jira connector resource name (if enabled) |
| `jira_connector_state` | State of the Jira data connector (if enabled) |

### Confluence Connector Outputs

| Output | Description |
|--------|-------------|
| `confluence_connector_name` | Full Confluence connector resource name (if enabled) |
| `confluence_connector_state` | State of the Confluence data connector (if enabled) |

### Google Workspace Connector Outputs

| Output | Description |
|--------|-------------|
| `mail_connector_name` | Full Gmail connector resource name (if enabled) |
| `mail_connector_state` | State of the Gmail data connector (if enabled) |
| `calendar_connector_name` | Full Calendar connector resource name (if enabled) |
| `calendar_connector_state` | State of the Calendar data connector (if enabled) |
| `drive_connector_name` | Full Drive connector resource name (if enabled) |
| `drive_connector_state` | State of the Drive data connector (if enabled) |

### Salesforce Connector Outputs

| Output | Description |
|--------|-------------|
| `salesforce_connector_name` | Full Salesforce connector resource name (if enabled) |
| `salesforce_connector_state` | State of the Salesforce data connector (if enabled) |

### Widget Configuration Outputs

| Output | Description |
|--------|-------------|
| `widget_config_id` | Widget configuration ID (if enabled) |
| `widget_config_name` | Full widget configuration resource name (if enabled) |

### Convenience Outputs

| Output | Description |
|--------|-------------|
| `project_id` | Project ID where resources were created |
| `console_url` | URL to the Gemini Enterprise console |
| `vertex_ai_search_url` | URL to the Vertex AI Search webapp (requires cid from console) |

## Directory Structure

```
.
├── main.tf                           # Root module configuration
├── variables.tf                      # Root variable declarations
├── outputs.tf                        # Root outputs
├── providers.tf                      # Provider configuration
├── versions.tf                       # Version constraints
├── terraform.tfvars                  # Variable values (git-ignored)
├── terraform.tfvars.example          # Example variable values
└── modules/
    └── gemini-enterprise/
        ├── main.tf                   # License config, search engine, widget
        ├── versions.tf               # Provider version constraints
        ├── variables.tf              # Module variables
        ├── outputs.tf                # Module outputs
        ├── jira.tf                   # Jira Cloud data connector
        ├── confluence.tf             # Confluence Cloud data connector
        ├── mail.tf                   # Gmail data connector
        ├── calendar.tf               # Google Calendar data connector
        ├── drive.tf                  # Google Drive data connector
        ├── salesforce.tf             # Salesforce data connector
```

## Troubleshooting

### Jira Connector Issues

**Error: Secrets not found**
```
Error: Error reading secret: googleapi: Error 404: Secret not found
```
Ensure secrets are created with exact names: `ONIX_JIRA_INTEGRATION_CLIENTID`, `ONIX_JIRA_INTEGRATION_SECRET`, `ONIX_JIRA_INTEGRATION_REFRESH_TOKEN`

**Error: Invalid entity type**
```
Error: entity type "issues" is invalid
```
Use singular entity names (e.g., `issue` not `issues`)

**Error: Data stores not found**
```
Error: data_stores/xxx does not exist
```
Data connectors create data stores asynchronously. Data store names follow the pattern `{collection_id}_{entity_name}`. If this error occurs, verify that the connector has successfully connected and created data stores in the Google Cloud Console, then run `terraform apply` again.

### Confluence Connector Issues

**Error: Confluence secrets not found**
```
Error: Error reading secret: googleapi: Error 404: Secret not found
```
Ensure secrets are created with exact names: `ONIX_CONFLUENCE_INTEGRATION_CLIENTID`, `ONIX_CONFLUENCE_INTEGRATION_SECRET`, `ONIX_CONFLUENCE_INTEGRATION_REFRESH_TOKEN`

**Error: Invalid Confluence entity type**
```
Error: Entity type must be one of: space, page, blog, attachment, comment, whiteboard
```
Use only supported entity types for Confluence.

### License Configuration Issues

**Error: License already exists**

License configurations are singleton resources per project. If one already exists, either import it or set `enable_license_config = false`.

### API Not Enabled

```
Error: Error enabling service: googleapi: Error 403: API has not been enabled
```
Ensure the service account has `serviceusage.services.enable` permission.

### Salesforce Connector Issues

**Error: Salesforce secrets not found**
```
Error: Error reading secret: googleapi: Error 404: Secret not found
```
Ensure secrets are created with exact names: `ONIX_SALESFORCE_ZOWIE_KEY`, `ONIX_SALESFORCE_ZOWIE_SECRET`

**Error: Invalid Salesforce entity**
```
Error: Entity type must be one of: lead, opportunity, contact, account, case, contract, campaign
```
Use only supported entity types for Salesforce.

### Google Workspace Connector Issues

**Error: Invalid entity name for workspace connectors**

Google Workspace connectors have fixed entity names:
- Gmail: `google_mail`
- Calendar: `google_calendar`
- Drive: `google_drive`

## References

- [Gemini for Google Cloud Documentation](https://cloud.google.com/gemini/docs)
- [Discovery Engine Documentation](https://cloud.google.com/generative-ai-app-builder/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Discovery Engine Data Connector](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/discovery_engine_data_connector)
- [Jira Cloud REST API](https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/)
- [Confluence Cloud REST API](https://developer.atlassian.com/cloud/confluence/rest/v2/intro/)
- [Salesforce Connected Apps](https://help.salesforce.com/s/articleView?id=sf.connected_app_overview.htm)
