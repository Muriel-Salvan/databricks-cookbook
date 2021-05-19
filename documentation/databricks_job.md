# databricks_job

[Back to resource list](../README.md#resources)

Handles a [job](https://docs.databricks.com/jobs.html).

## Actions

- `:create` (default).

## Properties

| Name | Type | Default | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| `name` (default) | String | None | Job name | Any Databricks job name |
| `job_id` | Integer | Retrieved from the API from the name | Job ID | Any Databricks job ID |
| `settings` | Hash | None | Settings to be given to the job creation Databricks API | Any setting as documented by the [Databricks Job API](https://docs.databricks.com/dev-tools/api/latest/jobs.html#create) |
| `host` | String | Host defined by `on_databricks` helper | Databricks host to connect to. | Any URL |
| `token` | String | Token defined by `on_databricks` helper | Databricks token used to connect to the REST API 2.0. | Any token |

## Examples

### Create a job

```ruby
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
```
