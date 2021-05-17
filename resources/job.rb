default_action :create

# Hash: Settings for this job
property :settings, Hash, required: true

include DatabricksResource

action :create do
  ruby_block "Create Databricks job #{new_resource.name}" do
    block do
      databricks_api.jobs.create(**new_resource.settings.merge(name: new_resource.name))
    end
    not_if do
      databricks_api.jobs.list.any? { |job_info| job_info.settings['name'] == new_resource.name }
    end
  end
end
