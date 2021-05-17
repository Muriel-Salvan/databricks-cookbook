# Define a scoped default host/token for the Databricks API access
#
# Parameters::
# * *host* (String): The Databricks host to target
# * *token* (String): The Databricks token to use
# * Proc: Client code that can use resources using those host and token
def on_databricks(host, token)
  node.run_state['databricks'] = {} unless node.run_state['databricks']
  node.run_state['databricks']['host'] = host
  node.run_state['databricks']['token'] = token
  yield
  node.run_state['databricks'].delete('host')
  node.run_state['databricks'].delete('token')
end
