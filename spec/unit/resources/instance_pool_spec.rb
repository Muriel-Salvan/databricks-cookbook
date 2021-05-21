describe 'databricks_instance_pool' do

  # Don't mock this resource, as this is the one to be tested
  step_into :databricks_instance_pool
  platform 'ubuntu'

  context 'with explicit properties' do

    recipe do
      databricks_instance_pool 'Test instance pool' do
        settings(
          node_type_id: 'i3.xlarge',
          min_idle_instances: 10,
          aws_attributes: {
            availability: 'SPOT'
          }
        )
        host 'https://my-databricks.my-domain.com'
        token 'my-databricks-token'
      end
    end

    it 'creates the instance pool when missing' do
      stub_request(:get, 'https://my-databricks.my-domain.com/api/2.0/instance-pools/list').
        with(body: {}).
        to_return(body: { instance_pools: [] }.to_json)
      stub_request(:post, 'https://my-databricks.my-domain.com/api/2.0/instance-pools/create').
        with(
          body: {
            instance_pool_name: 'Test instance pool',
            node_type_id: 'i3.xlarge',
            min_idle_instances: 10,
            aws_attributes: {
              availability: 'SPOT'
            }
          }
        ).
        to_return(body: { instance_pool_id: '0101-120000-brick1-pool-ABCD1234' }.to_json)
      expect { chef_run }.not_to raise_error
    end

    it 'does not create the instance pool when existing' do
      stub_request(:get, 'https://my-databricks.my-domain.com/api/2.0/instance-pools/list').
        with(body: {}).
        to_return(body: { instance_pools: [
          {
            instance_pool_name: 'Test instance pool',
            node_type_id: 'i3.xlarge',
            min_idle_instances: 10,
            aws_attributes: {
              availability: 'SPOT'
            },
            instance_pool_id: '0101-120000-brick1-pool-ABCD1234',
            default_tags: [
              { DatabricksInstancePoolCreatorId: '1234' },
              { DatabricksInstancePoolId: '0101-120000-brick1-pool-ABCD1234' }
            ],
            stats: {
              used_count: 10,
              idle_count: 5,
              pending_used_count: 5,
              pending_idle_count: 5
            }
          }
        ] }.to_json)
      expect { chef_run }.not_to raise_error
    end

    it 'edits the instance pool when different' do
      stub_request(:get, 'https://my-databricks.my-domain.com/api/2.0/instance-pools/list').
        with(body: {}).
        to_return(body: { instance_pools: [
          {
            instance_pool_name: 'Test instance pool',
            node_type_id: 'i3.xlarge',
            min_idle_instances: 8,
            aws_attributes: {
              availability: 'SPOT'
            },
            instance_pool_id: '0101-120000-brick1-pool-ABCD1234',
            default_tags: [
              { DatabricksInstancePoolCreatorId: '1234' },
              { DatabricksInstancePoolId: '0101-120000-brick1-pool-ABCD1234' }
            ],
            stats: {
              used_count: 10,
              idle_count: 5,
              pending_used_count: 5,
              pending_idle_count: 5
            }
          }
        ] }.to_json)
      stub_request(:get, 'https://my-databricks.my-domain.com/api/2.0/instance-pools/get').
        with(body: { instance_pool_id: '0101-120000-brick1-pool-ABCD1234' }).
        to_return(body: {
          instance_pool_name: 'Test instance pool',
          node_type_id: 'i3.xlarge',
          min_idle_instances: 10,
          aws_attributes: {
            availability: 'SPOT'
          },
          instance_pool_id: '0101-120000-brick1-pool-ABCD1234',
          default_tags: [
            { DatabricksInstancePoolCreatorId: '1234' },
            { DatabricksInstancePoolId: '0101-120000-brick1-pool-ABCD1234' }
          ],
          stats: {
            used_count: 10,
            idle_count: 5,
            pending_used_count: 5,
            pending_idle_count: 5
          }
        }.to_json)
      stub_request(:post, 'https://my-databricks.my-domain.com/api/2.0/instance-pools/edit').
        with(
          body: {
            instance_pool_name: 'Test instance pool',
            instance_pool_id: '0101-120000-brick1-pool-ABCD1234',
            node_type_id: 'i3.xlarge',
            min_idle_instances: 10,
            aws_attributes: {
              availability: 'SPOT'
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
        databricks_instance_pool 'Test instance pool' do
          settings(
            node_type_id: 'i3.xlarge',
            min_idle_instances: 10,
            aws_attributes: {
              availability: 'SPOT'
            }
          )
        end
      end
    end

    it 'uses default host and token' do
      stub_request(:get, 'https://my-databricks.my-domain.com/api/2.0/instance-pools/list').
        with(body: {}).
        to_return(body: { instance_pools: [] }.to_json)
      stub_request(:post, 'https://my-databricks.my-domain.com/api/2.0/instance-pools/create').
        with(
          body: {
            instance_pool_name: 'Test instance pool',
            node_type_id: 'i3.xlarge',
            min_idle_instances: 10,
            aws_attributes: {
              availability: 'SPOT'
            }
          }
        ).
        to_return(body: { instance_pool_id: '0101-120000-brick1-pool-ABCD1234' }.to_json)
      expect { chef_run }.not_to raise_error
    end

  end

  context 'with globally set host and token' do

    recipe do
      on_databricks('https://my-databricks.my-domain.com', 'my-databricks-token')
      databricks_instance_pool 'Test instance pool' do
        settings(
          node_type_id: 'i3.xlarge',
          min_idle_instances: 10,
          aws_attributes: {
            availability: 'SPOT'
          }
        )
      end
    end

    it 'uses default host and token' do
      stub_request(:get, 'https://my-databricks.my-domain.com/api/2.0/instance-pools/list').
        with(body: {}).
        to_return(body: { instance_pools: [] }.to_json)
      stub_request(:post, 'https://my-databricks.my-domain.com/api/2.0/instance-pools/create').
        with(
          body: {
            instance_pool_name: 'Test instance pool',
            node_type_id: 'i3.xlarge',
            min_idle_instances: 10,
            aws_attributes: {
              availability: 'SPOT'
            }
          }
        ).
        to_return(body: { instance_pool_id: '0101-120000-brick1-pool-ABCD1234' }.to_json)
      expect { chef_run }.not_to raise_error
    end

  end

end
