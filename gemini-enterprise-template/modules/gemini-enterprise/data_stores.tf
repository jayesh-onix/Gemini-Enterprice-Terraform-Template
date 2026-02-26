# =============================================================================
# Standalone Cloud Data Stores
# =============================================================================
# Creates Discovery Engine data stores for sources that are not managed via
# connectors. Used for Announcements, custom structured/unstructured data,
# and other standalone data sources.
#
# These data stores are automatically linked to the search engine via
# local.effective_data_store_ids.
# =============================================================================

resource "google_discovery_engine_data_store" "cloud" {
  for_each = local.enabled_cloud_data_stores

  provider = google
  project  = var.project_id
  location = var.location

  data_store_id                = each.value.data_store_id
  display_name                 = each.value.display_name
  industry_vertical            = each.value.industry_vertical
  content_config               = each.value.content_config
  solution_types               = each.value.solution_types
  create_advanced_site_search  = each.value.create_advanced_site_search
  skip_default_schema_creation = each.value.skip_default_schema_creation

  lifecycle {
    ignore_changes = all
  }

  depends_on = [
    google_project_service.discoveryengine,
    google_discovery_engine_license_config.main
  ]
}
