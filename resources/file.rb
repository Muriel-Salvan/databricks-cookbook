default_action :create

# String: Path to the source of the file
property :source, String, required: true

include DatabricksResource

action :create do
  ruby_block "Put Databricks file #{new_resource.name}" do
    block do
      databricks_api.dbfs.put(
        new_resource.name,
        run_context.cookbook_collection[cookbook_name].preferred_filename_on_disk_location(run_context.node, :files, new_resource.source)
      )
    end
    not_if do
      found = false
      begin
        found = databricks_api.dbfs.list(new_resource.name).first.path == new_resource.name
      rescue RestClient::NotFound
        found = false
      end
      found
    end
  end
end
