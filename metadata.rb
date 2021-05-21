name 'databricks'
maintainer 'Muriel Salvan'
maintainer_email 'muriel@x-aeon.com'
license 'BSD-3-Clause'
description 'Installs/Configures Databricks resources'
version '0.1.2'
chef_version '>= 15.0'
source_url 'https://github.com/Muriel-Salvan/databricks-cookbook'
issues_url 'https://github.com/Muriel-Salvan/databricks-cookbook/issues'

# Cookbook dependencies
# Access the Databricks REST API 2.0
gem 'databricks', '~> 2.3'
# Display sexy diffs of resources
gem 'diffy', '~> 3.4'
