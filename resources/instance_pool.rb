default_action :create

# Hash: Settings for this instance pool
property :settings, Hash

include DatabricksResource

databricks_resource_actions(
  :instance_pools,
  :instance_pool_name,
  :instance_pool_id,
  settings_properties_to_ignore: %i[stats state status default_tags]
)
