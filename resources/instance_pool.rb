default_action :create

# Hash: Settings for this instance pool
property :settings, Hash
# String: The instance pool ID
property :instance_pool_id, String

include DatabricksResource

databricks_resource_actions(
  :instance_pools,
  :instance_pool_name,
  :instance_pool_id,
  settings_properties_to_ignore: %i[stats state status default_tags]
)
