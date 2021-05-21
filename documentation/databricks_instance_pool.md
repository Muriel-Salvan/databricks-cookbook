# databricks_instance_pool

[Back to resource list](../README.md#resources)

Handles a [Databricks instance pool](https://docs.databricks.com/clusters/instance-pools/index.html).

## Actions

- `:create` (default).

## Properties

| Name | Type | Default | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| `name` (default) | String | None | Instance pool name | Any pool name |
| `settings` | Hash | None | Settings to be given to the instance pool creation Databricks API | Any setting as documented by the [Databricks Instance Pools API](https://docs.databricks.com/dev-tools/api/latest/instance-pools.html#create) |
| `host` | String | Host defined by `on_databricks` helper | Databricks host to connect to. | Any URL |
| `token` | String | Token defined by `on_databricks` helper | Databricks token used to connect to the REST API 2.0. | Any token |

## Examples

### Create an instance pool

```ruby
databricks_instance_pool 'my-pool' do
  settings(
    node_type_id: 'i3.xlarge',
    min_idle_instances: 10,
    aws_attributes: {
      availability: 'SPOT'
    }
  )
end
```
