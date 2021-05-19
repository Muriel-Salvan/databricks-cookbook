# Helpers that are added any Databricks resource class
module DatabricksResourceClassHelpers

  # Register the Databricks API properties needed to select the resource from a list with name and id attributes.
  # If a settings property is to be set, automatically set it from the Databricks resource that is selected.
  #
  # Parameters::
  # * *resource_type* (Symbol): The resource type
  # * *name_attribute* (Symbol): The name attribute from the resources of this type
  # * *id_attribute* (Symbol): The id attribute from the resources of this type
  # * *settings_properties_to_ignore* (Array<Symbol>): List of properties to ignore when initializing the current resource (ignored if the resource has no settings property) [default: []]
  # * *block* (Proc): Optional code called to initialize the current state of a selected resource, the same way the block to load_current_value does.
  #   * Parameters::
  #     * *found_resource* (Databricks::Resource): The resource that has been selected, and which corresponds to the current state.
  def load_current_value_from(resource_type, name_attribute, id_attribute, settings_properties_to_ignore: [], &block)
    load_current_value do |new_resource|
      resources = databricks_api.send(resource_type).list
      # If the ID was given, use it to select the resource, otherwise use the name
      id_to_select = new_resource.send(id_attribute)
      found_resource =
        if id_to_select
          resources.find { |resource| resource.send(id_attribute) == id_to_select }
        else
          name_to_select = new_resource.name
          resources.find { |resource| resource.send(name_attribute) == name_to_select }
        end
      if found_resource
        # Set the current resource's attributes based on the Databricks resource that has been selected
        name found_resource.send(name_attribute)
        self.send(id_attribute, found_resource.send(id_attribute))
        if self.respond_to?(:settings)
          properties_to_ignore = [name_attribute, id_attribute] + settings_properties_to_ignore
          settings found_resource.properties.reject { |property, _value| properties_to_ignore.include?(property) }
        end
        instance_exec(found_resource, &block) unless block.nil?
        # Set the new resource ID unless it was already forced by the calling recipe
        new_resource.send(id_attribute, found_resource.send(id_attribute)) if id_to_select.nil?
      end
    end
  end

  # Register default actions and current resource loading for Databricks resources having names, ids and settings.
  #
  # Parameters::
  # * *resource_type* (Symbol): The resource type
  # * *name_attribute* (Symbol): The name attribute from the resources of this type
  # * *id_attribute* (Symbol): The id attribute from the resources of this type
  # * *settings_properties_to_ignore* (Array<Symbol>): List of properties to ignore when initializing the current resource (ignored if the resource has no settings property) [default: []]
  # * *load_current_value_proc* (Proc or nil): Optional code called to initialize the current state of a selected resource, the same way the block to load_current_value does. [default: nil]
  #   * Parameters::
  #     * *found_resource* (Databricks::Resource): The resource that has been selected, and which corresponds to the current state.
  # * *update_action* (Proc or nil): Optional code to be called to update a resource, or nil if the default action (calling edit API) is to be used [default: nil]
  #   * Parameters::
  #     * *new_resource* (Resource): The new resource containing properties to be updated
  def databricks_resource_actions(
    resource_type,
    name_attribute,
    id_attribute,
    settings_properties_to_ignore: [],
    load_current_value_proc: nil,
    update_action: nil
  )
    load_current_value_from(resource_type, name_attribute, id_attribute, settings_properties_to_ignore: settings_properties_to_ignore, &load_current_value_proc)

    action :create do
      converge_if_changed do
        new_resource_id = new_resource.send(id_attribute)
        new_resource_name = new_resource.name
        if new_resource_id.nil?
          databricks_api.send(resource_type).create(**new_resource.settings.merge(name_attribute => new_resource_name))
        else
          if update_action.nil?
            databricks_api.send(resource_type).get(new_resource_id).reset(**new_resource.settings.merge(name_attribute => new_resource_name))
          else
            update_action.call(new_resource)
          end
        end
      end
    end
  end

end
