require 'databricks'

# Define common behaviours for all resources
module DatabricksResource
  # All our resources are unified
  def self.included(including)
    including.class_eval do
      unified_mode true

      # Define common properties
      # String: Databricks host, defaults to the host set by on_databricks
      property :host, String, desired_state: false
      # String: Databricks token, defaults to the token set by on_databricks
      property :token, String, desired_state: false

      # Add helpers to actions
      action_class do
        prepend ActionClassHelpers
      end

      # Add class helpers
      extend DatabricksResourceClassHelpers
    end
  end

  # Hook called right after the resource's creation, at compile time.
  def after_created
    super
    # Set the default host and token to what could have been set in a with_databricks_access scope
    host node.run_state.dig('databricks', 'host') if host.nil?
    token node.run_state.dig('databricks', 'token') if token.nil?
  end

  # Get access to the Databricks API pointed by the resource
  #
  # Result::
  # * ::Databricks::Resources::Root: The root resource of the Databricks API (see the databricks gem: https://github.com/Muriel-Salvan/databricks/ )
  def databricks_api
    ::Databricks.api(host, token)
  end
end
