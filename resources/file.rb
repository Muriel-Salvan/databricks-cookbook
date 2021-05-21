default_action :create

# String: Path to the source of the file
property :source, String

# Internal properties: those should not be set by the recipe but are used internally.
# Integer: File size
property :__file_size, Integer

include DatabricksResource

# Hook called right after the resource's creation, at compile time.
def after_created
  super
  __file_size ::File.size(run_context.cookbook_collection[cookbook_name].preferred_filename_on_disk_location(run_context.node, :files, source))
end

load_current_value do |new_resource|
  found =
    begin
      databricks_api.dbfs.list(name).first
    rescue RestClient::NotFound
      nil
    end
  source new_resource.source
  __file_size found.file_size unless found.nil?
end

action :create do
  converge_if_changed do
    databricks_api.dbfs.put(
      new_resource.name,
      run_context.cookbook_collection[cookbook_name].preferred_filename_on_disk_location(run_context.node, :files, new_resource.source)
    )
  end
end
