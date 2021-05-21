# databricks Cookbook

Configures a [Databricks](https://databricks.com/) workspace, using the [Databricks REST API 2.0](https://docs.databricks.com/dev-tools/api/index.html).

## Requirements

### Rubygems

The following gems are installed automatically by your Chef client when using this cookbook, as part of its main dependencies:

- [`databricks`](https://github.com/Muriel-Salvan/databricks) to access the Databricks REST API.

### Platforms

The following platforms are supported and tested with Test Kitchen:

TODO: Compile the exact list when Test Kitchen will be fully configured.

### Chef

- Chef 15+

## Resources

- [databricks_file](documentation/databricks_file.md)
- [databricks_job](documentation/databricks_job.md)
- [databricks_instance_pool](documentation/databricks_instance_pool.md)

## Usage

This cookbook is resource-based. Use the resources described above in wrapper cookbooks or recipes.

Each resource uses attributes `host` and `token` to know the Databricks host to target, and the token used in the REST API queries.

If you want to group all resources accessed under the same host and token, you can use the `on_databricks` helper that provides a scope to define such resources.
Then resources defined in such a scope will use the given host and token as default values.

Example:
```ruby
on_databricks('https://my-databricks.net', 'my-token') do

  databricks_file '/FileStore/txt/test.txt' do
    source 'test.txt'
  end

  databricks_job 'Test job' do
    settings(
      new_cluster: {
        spark_version: '7.4.x-scala2.12',
        node_type_id: 'Standard_DS3_v2',
        enable_elastic_disk: true,
        num_workers: 2
      },
      timeout_seconds: 0,
      max_concurrent_runs: 1
    )
  end

end
```

## Development

### Development workflow

A standard PR-based development workflow is applied to this repository, using a single master release branch and linear strategy.

If you want to contribute to the code, please create a fork of the repository in your Github's user space, then push a branch with your modifications on your fork and create a PR from it to the master branch on the main repository.

### Testing

Lint testing can be done using Chef's `delivery` tool:
```bash
/opt/chef-workstation/bin/delivery local lint
```

Unit testing can be done using Chefspec.
Unit testing needs [webmock](https://github.com/bblimke/webmock) to run, so you will have to install it as part of your Chef workstation's gems:
```bash
/opt/chef-workstation/embedded/bin/gem install webmock
```

Then unit tests can be run like this:
```bash
/opt/chef-workstation/bin/chef exec rspec
```
