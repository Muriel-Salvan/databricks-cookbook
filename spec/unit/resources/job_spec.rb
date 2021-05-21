describe 'databricks_job' do

  # Don't mock this resource, as this is the one to be tested
  step_into :databricks_job
  platform 'ubuntu'

  context 'with explicit properties' do

    recipe do
      databricks_job 'Test job' do
        settings(
          new_cluster: {
            spark_version: '7.3.x-scala2.12',
            node_type_id: 'r3.xlarge',
            aws_attributes: {
              availability: 'ON_DEMAND'
            },
            num_workers: 10
          }
        )
        host 'https://my-databricks.my-domain.com'
        token 'my-databricks-token'
      end
    end

    it 'creates the job when missing' do
      stub_request(:get, 'https://my-databricks.my-domain.com/api/2.0/jobs/list').
        with(body: {}).
        to_return(body: { jobs: [] }.to_json)
      stub_request(:post, 'https://my-databricks.my-domain.com/api/2.0/jobs/create').
        with(
          body: {
            name: 'Test job',
            new_cluster: {
              spark_version: '7.3.x-scala2.12',
              node_type_id: 'r3.xlarge',
              aws_attributes: {
                availability: 'ON_DEMAND'
              },
              num_workers: 10
            }
          }
        ).
        to_return(body: { job_id: 666 }.to_json)
      expect { chef_run }.not_to raise_error
    end

    it 'does not create the job when existing' do
      stub_request(:get, 'https://my-databricks.my-domain.com/api/2.0/jobs/list').
        with(body: {}).
        to_return(body: { jobs: [
          {
            job_id: 666,
            settings: {
              name: 'Test job',
              new_cluster: {
                spark_version: '7.3.x-scala2.12',
                node_type_id: 'r3.xlarge',
                aws_attributes: {
                  availability: 'ON_DEMAND'
                },
                num_workers: 10
              }
            },
            created_time: 1457570074236
          }
        ] }.to_json)
      expect { chef_run }.not_to raise_error
    end

    it 'resets the job when different' do
      stub_request(:get, 'https://my-databricks.my-domain.com/api/2.0/jobs/list').
        with(body: {}).
        to_return(body: { jobs: [
          {
            job_id: 666,
            settings: {
              name: 'Test job',
              new_cluster: {
                spark_version: '7.3.x-scala2.12',
                node_type_id: 'r3.xlarge',
                aws_attributes: {
                  availability: 'ON_DEMAND'
                },
                num_workers: 8
              }
            },
            created_time: 1457570074236
          }
        ] }.to_json)
      stub_request(:get, 'https://my-databricks.my-domain.com/api/2.0/jobs/get').
        with(body: { job_id: 666 }).
        to_return(body: {
          job_id: 666,
          settings: {
            name: 'Test job',
            new_cluster: {
              spark_version: '7.3.x-scala2.12',
              node_type_id: 'r3.xlarge',
              aws_attributes: {
                availability: 'ON_DEMAND'
              },
              num_workers: 8
            }
          },
          created_time: 1457570074236
        }.to_json)
      stub_request(:post, 'https://my-databricks.my-domain.com/api/2.0/jobs/reset').
        with(
          body: {
            job_id: 666,
            new_settings: {
              name: 'Test job',
              new_cluster: {
                spark_version: '7.3.x-scala2.12',
                node_type_id: 'r3.xlarge',
                aws_attributes: {
                  availability: 'ON_DEMAND'
                },
                num_workers: 10
              }
            }
          }
        ).
        to_return(body: {}.to_json)
      expect { chef_run }.not_to raise_error
    end

  end

  context 'with host and token scope' do

    recipe do
      on_databricks('https://my-databricks.my-domain.com', 'my-databricks-token') do
        databricks_job 'Test job' do
          settings(
            new_cluster: {
              spark_version: '7.3.x-scala2.12',
              node_type_id: 'r3.xlarge',
              aws_attributes: {
                availability: 'ON_DEMAND'
              },
              num_workers: 10
            }
          )
          host 'https://my-databricks.my-domain.com'
          token 'my-databricks-token'
        end
      end
    end

    it 'uses default host and token' do
      stub_request(:get, 'https://my-databricks.my-domain.com/api/2.0/jobs/list').
        with(body: {}).
        to_return(body: { jobs: [] }.to_json)
      stub_request(:post, 'https://my-databricks.my-domain.com/api/2.0/jobs/create').
        with(
          body: {
            name: 'Test job',
            new_cluster: {
              spark_version: '7.3.x-scala2.12',
              node_type_id: 'r3.xlarge',
              aws_attributes: {
                availability: 'ON_DEMAND'
              },
              num_workers: 10
            }
          }
        ).
        to_return(body: { job_id: 666 }.to_json)
      expect { chef_run }.not_to raise_error
    end

  end

  context 'with globally set host and token' do

    recipe do
      on_databricks('https://my-databricks.my-domain.com', 'my-databricks-token')
      databricks_job 'Test job' do
        settings(
          new_cluster: {
            spark_version: '7.3.x-scala2.12',
            node_type_id: 'r3.xlarge',
            aws_attributes: {
              availability: 'ON_DEMAND'
            },
            num_workers: 10
          }
        )
        host 'https://my-databricks.my-domain.com'
        token 'my-databricks-token'
      end
    end

    it 'uses default host and token' do
      stub_request(:get, 'https://my-databricks.my-domain.com/api/2.0/jobs/list').
        with(body: {}).
        to_return(body: { jobs: [] }.to_json)
      stub_request(:post, 'https://my-databricks.my-domain.com/api/2.0/jobs/create').
        with(
          body: {
            name: 'Test job',
            new_cluster: {
              spark_version: '7.3.x-scala2.12',
              node_type_id: 'r3.xlarge',
              aws_attributes: {
                availability: 'ON_DEMAND'
              },
              num_workers: 10
            }
          }
        ).
        to_return(body: { job_id: 666 }.to_json)
      expect { chef_run }.not_to raise_error
    end

  end

end
