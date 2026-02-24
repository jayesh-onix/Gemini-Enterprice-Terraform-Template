# Gemini Enterprise Module

This Terraform module deploys Google Gemini Enterprise with Discovery Engine resources, including license configuration and search engine setup.

## Description

This module creates:

- **Discovery Engine License Configuration** - Manages Gemini Enterprise licensing with configurable subscription tiers and terms

- **Discovery Engine Search Engine** - Enterprise search engine with LLM-powered capabilities for intranet applications

## Usage

### Basic Example (Free Trial)

```hcl
module "gemini_enterprise" {
  source = "./modules/gemini-enterprise"

  project_id = "my-project-id"
  engine_id  = "gemini-enterprise-app"

  start_date = {
    year  = 2025
    month = 12
    day   = 19
  }
  end_date = {
    year  = 2026
    month = 1
    day   = 17
  }
}
```

### Production Example

```hcl
module "gemini_enterprise" {
  source = "./modules/gemini-enterprise"

  project_id          = "my-project-id"
  engine_id           = "gemini-enterprise-prod"
  engine_display_name = "Gemini Enterprise Production"
  location            = "us"

  # License configuration
  license_count     = 100
  free_trial        = false
  subscription_tier = "SUBSCRIPTION_TIER_ENTERPRISE"
  subscription_term = "SUBSCRIPTION_TERM_ONE_YEAR"

  start_date = {
    year  = 2025
    month = 1
    day   = 1
  }
  end_date = {
    year  = 2026
    month = 1
    day   = 1
  }

  # Search engine configuration
  search_tier    = "SEARCH_TIER_ENTERPRISE"
  search_add_ons = ["SEARCH_ADD_ON_LLM"]
  data_store_ids = ["my-data-store-id"]
}
```

### Without License Configuration

```hcl
module "gemini_enterprise" {
  source = "./modules/gemini-enterprise"

  project_id            = "my-project-id"
  engine_id             = "gemini-enterprise-app"
  enable_license_config = false

  # Dummy dates (not used when license config is disabled)
  start_date = { year = 2025, month = 1, day = 1 }
  end_date   = { year = 2025, month = 12, day = 31 }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| google | ~> 7.0 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 7.0 |

## Resources

| Name | Type |
|------|------|
| google_project_service.discoveryengine | resource |
| google_discovery_engine_license_config.main | resource |
| google_discovery_engine_search_engine.main | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | The GCP project ID where Gemini Enterprise resources will be created | `string` | n/a | yes |
| engine_id | Unique identifier for the Gemini Enterprise search engine | `string` | n/a | yes |
| start_date | Start date for the license subscription | `object({year=number, month=number, day=number})` | n/a | yes |
| end_date | End date for the license subscription | `object({year=number, month=number, day=number})` | n/a | yes |
| location | Location for Discovery Engine resources (global, us, eu) | `string` | `"global"` | no |
| collection_id | Collection ID for the search engine | `string` | `"default_collection"` | no |
| enable_license_config | Whether to create a license configuration | `bool` | `true` | no |
| license_config_id | Unique identifier for the license configuration | `string` | `null` | no |
| license_count | Number of licenses to provision | `number` | `25` | no |
| free_trial | Whether this is a free trial license | `bool` | `true` | no |
| subscription_tier | Subscription tier (SUBSCRIPTION_TIER_STANDARD, SUBSCRIPTION_TIER_ENTERPRISE) | `string` | `"SUBSCRIPTION_TIER_ENTERPRISE"` | no |
| subscription_term | Subscription term length | `string` | `"SUBSCRIPTION_TERM_ONE_MONTH"` | no |
| engine_display_name | Display name for the search engine | `string` | `null` | no |
| data_store_ids | List of data store IDs to associate with the search engine | `list(string)` | `[]` | no |
| app_type | Application type (APP_TYPE_INTRANET, APP_TYPE_INTERNET) | `string` | `"APP_TYPE_INTRANET"` | no |
| search_tier | Search tier (SEARCH_TIER_STANDARD, SEARCH_TIER_ENTERPRISE) | `string` | `"SEARCH_TIER_ENTERPRISE"` | no |
| search_add_ons | List of search add-ons to enable | `list(string)` | `["SEARCH_ADD_ON_LLM"]` | no |
| enable_discovery_engine_api | Whether to enable the Discovery Engine API | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| license_config_id | The ID of the created license configuration |
| license_config_name | The full resource name of the license configuration |
| license_count | The number of licenses provisioned |
| subscription_tier | The subscription tier of the license |
| engine_id | The ID of the created search engine |
| engine_name | The full resource name of the search engine |
| engine_display_name | The display name of the search engine |
| engine_location | The location of the search engine |
| engine_collection_id | The collection ID of the search engine |
| app_type | The application type of the search engine |
| search_tier | The search tier configured for the engine |
| search_add_ons | The search add-ons enabled for the engine |
| project_id | The project ID where resources were created |
| console_url | URL to the Gemini Enterprise console |

## Notes

- The `engine_id` must be lowercase, start with a letter, and contain only letters, numbers, and hyphens
- License configuration requires valid start and end dates
- The Discovery Engine API is automatically enabled unless `enable_discovery_engine_api` is set to `false`
- When `enable_license_config` is `false`, the `start_date` and `end_date` variables are still required but not used

## License

Apache 2.0
