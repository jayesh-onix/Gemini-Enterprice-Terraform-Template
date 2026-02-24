# -----------------------------------------------------------------------------
# Local Computations
# Derives data store IDs, filters enabled connectors, and flattens secrets
# -----------------------------------------------------------------------------

locals {
  # -------------------------------------------------------------------------
  # Filter enabled connectors
  # -------------------------------------------------------------------------
  enabled_third_party_connectors = {
    for k, v in var.third_party_connectors : k => v if v.enabled
  }

  enabled_workspace_connectors = {
    for k, v in var.workspace_connectors : k => v if v.enabled
  }

  # -------------------------------------------------------------------------
  # Flatten all secrets across third-party connectors for batch lookup
  # Key format: "connector_key/secret_key" => { connector_key, secret_key, secret_id }
  # -------------------------------------------------------------------------
  connector_secrets_flat = merge([
    for conn_key, conn in local.enabled_third_party_connectors : {
      for secret_key, secret_id in conn.secrets :
      "${conn_key}/${secret_key}" => {
        connector_key = conn_key
        secret_key    = secret_key
        secret_id     = secret_id
      }
    }
  ]...)

  # -------------------------------------------------------------------------
  # Whether we need the Discovery Engine service identity
  # (required for granting secret access to 3rd-party connectors)
  # -------------------------------------------------------------------------
  needs_service_identity = length(local.enabled_third_party_connectors) > 0

  # -------------------------------------------------------------------------
  # Compute data store IDs for all connectors
  # These are used to link data stores to the search engine
  # Format: {collection_id}_{entity_name}
  # -------------------------------------------------------------------------
  third_party_data_store_ids = flatten([
    for conn_key, conn in local.enabled_third_party_connectors : [
      for entity in conn.entities : "${conn.collection_id}_${entity.entity_name}"
    ]
  ])

  workspace_data_store_ids = [
    for conn_key, conn in local.enabled_workspace_connectors :
    "${conn.collection_id}_${conn.entity.entity_name}"
  ]

  all_connector_data_store_ids = concat(
    local.third_party_data_store_ids,
    local.workspace_data_store_ids
  )

  # Use connector-derived data store IDs if any connectors are enabled,
  # otherwise fall back to explicitly provided data_store_ids
  effective_data_store_ids = length(local.all_connector_data_store_ids) > 0 ? (
    local.all_connector_data_store_ids
  ) : var.data_store_ids

  # -------------------------------------------------------------------------
  # Computed values
  # -------------------------------------------------------------------------
  license_config_id   = var.license_config_id != null ? var.license_config_id : "${var.project_id}-${var.engine_id}"
  engine_display_name = var.engine_display_name != null ? var.engine_display_name : var.engine_id
}
