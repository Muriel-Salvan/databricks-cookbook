default_action :create

# Hash: Settings for this instance pool
property :settings, Hash, required: true

include DatabricksResource

action :create do
  ruby_block "Create Databricks instance pool #{new_resource.name}" do
    block do
      databricks_api.instance_pools.create(**new_resource.settings.merge(instance_pool_name: new_resource.name))
    end
    not_if do
      databricks_api.instance_pools.list.any? { |instance_pool_info| instance_pool_info.instance_pool_name == new_resource.name }
    end
  end
end
