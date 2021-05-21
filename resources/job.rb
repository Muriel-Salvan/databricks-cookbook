default_action :create

# Hash: Settings for this job
property :settings, Hash

include DatabricksResource

databricks_resource_actions(
  :jobs,
  :name,
  :job_id,
  settings_properties_to_ignore: %i[created_time creator_user_name],
  update_action: proc do |new_resource|
    databricks_api.jobs.get(new_resource.__internal_id).reset(**new_resource.settings.merge(name: new_resource.name))
  end
)
