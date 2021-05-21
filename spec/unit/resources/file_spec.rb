describe 'databricks_file' do

  # Don't mock this resource, as this is the one to be tested
  step_into :databricks_file
  platform 'ubuntu'

  # Mock the test file system as if files were taken from a calling cookbook's files directory
  before :each do
    allow_any_instance_of(Chef::CookbookVersion).to receive(:preferred_filename_on_disk_location).and_wrap_original do |org, node, type, source|
      if source =~ %r{^test_files/(.*)$}
        # Give a path to our test repository files
        "spec/files/#{Regexp.last_match(1)}"
      else
        org.call node, type, source
      end
    end
  end

  # Extract multiform properties separated by Ruby RestClient delimiters from an HTTP body.
  #
  # Parameters::
  # * *body* (String): The HTTP  body containing multiform data
  # Result::
  # * Array: The parsed multiform data
  def parse_multiform(body)
    body.
      split(/------RubyFormBoundary.*\n/).
      map do |line|
        if line.strip.empty?
          nil
        else
          line.strip.split("\n").map { |section| section.strip.empty? ? nil : section.strip }.compact
        end
      end.
      compact
  end

  context 'with explicit properties' do

    recipe do
      databricks_file '/dbfs/path/to/file' do
        source 'test_files/example_file'
        host 'https://my-databricks.my-domain.com'
        token 'my-databricks-token'
      end
    end

    it 'creates the file when missing' do
      stub_request(:get, 'https://my-databricks.my-domain.com/api/2.0/dbfs/list').
        with(body: { path: '/dbfs/path/to/file' }).
        to_return(
          status: 404,
          body: { files: [] }.to_json
        )
      stub_request(:post, 'https://my-databricks.my-domain.com/api/2.0/dbfs/put').
        with do |request|
          # As body is a multiform containing unique IDs, sanitize it before checking content
          expect(parse_multiform(request.body)).to eq [
            ['Content-Disposition: form-data; name="path"', '/dbfs/path/to/file'],
            ['Content-Disposition: form-data; name="contents"; filename="example_file"', 'Content-Type: text/plain', 'Hello world!'],
            ['Content-Disposition: form-data; name="overwrite"', 'true']
          ]
        end.
        to_return(body: '')
      expect { chef_run }.not_to raise_error
    end

    it 'does not create the file when existing with the correct size' do
      file_size = File.size('spec/files/example_file')
      stub_request(:get, 'https://my-databricks.my-domain.com/api/2.0/dbfs/list').
        with(body: { path: '/dbfs/path/to/file' }).
        to_return(
          status: 200,
          body: { files: [
            {
              path: '/dbfs/path/to/file',
              is_dir: false,
              file_size: file_size,
              modification_time: 1610366757000
            }
          ] }.to_json
        )
      expect { chef_run }.not_to raise_error
    end

    it 'updates the file when existing with a different size' do
      file_size = File.size('spec/files/example_file')
      stub_request(:get, 'https://my-databricks.my-domain.com/api/2.0/dbfs/list').
        with(body: { path: '/dbfs/path/to/file' }).
        to_return(
          status: 200,
          body: { files: [
            {
              path: '/dbfs/path/to/file',
              is_dir: false,
              file_size: file_size + 5,
              modification_time: 1610366757000
            }
          ] }.to_json
        )
      stub_request(:post, 'https://my-databricks.my-domain.com/api/2.0/dbfs/put').
        with do |request|
          # As body is a multiform containing unique IDs, sanitize it before checking content
          expect(parse_multiform(request.body)).to eq [
            ['Content-Disposition: form-data; name="path"', '/dbfs/path/to/file'],
            ['Content-Disposition: form-data; name="contents"; filename="example_file"', 'Content-Type: text/plain', 'Hello world!'],
            ['Content-Disposition: form-data; name="overwrite"', 'true']
          ]
        end.
        to_return(body: '')
      expect { chef_run }.not_to raise_error
    end

  end

  context 'with host and token scope' do

    recipe do
      on_databricks('https://my-databricks.my-domain.com', 'my-databricks-token') do
        databricks_file '/dbfs/path/to/file' do
          source 'test_files/example_file'
        end
      end
    end

    it 'uses default host and token' do
      stub_request(:get, 'https://my-databricks.my-domain.com/api/2.0/dbfs/list').
        with(body: { path: '/dbfs/path/to/file' }).
        to_return(
          status: 404,
          body: { files: [] }.to_json
        )
      stub_request(:post, 'https://my-databricks.my-domain.com/api/2.0/dbfs/put').
        with do |request|
          # As body is a multiform containing unique IDs, sanitize it before checking content
          expect(parse_multiform(request.body)).to eq [
            ['Content-Disposition: form-data; name="path"', '/dbfs/path/to/file'],
            ['Content-Disposition: form-data; name="contents"; filename="example_file"', 'Content-Type: text/plain', 'Hello world!'],
            ['Content-Disposition: form-data; name="overwrite"', 'true']
          ]
        end.
        to_return(body: '')
      expect { chef_run }.not_to raise_error
    end

  end

  context 'with globally set host and token' do

    recipe do
      on_databricks('https://my-databricks.my-domain.com', 'my-databricks-token')
      databricks_file '/dbfs/path/to/file' do
        source 'test_files/example_file'
      end
    end

    it 'uses default host and token' do
      stub_request(:get, 'https://my-databricks.my-domain.com/api/2.0/dbfs/list').
        with(body: { path: '/dbfs/path/to/file' }).
        to_return(
          status: 404,
          body: { files: [] }.to_json
        )
      stub_request(:post, 'https://my-databricks.my-domain.com/api/2.0/dbfs/put').
        with do |request|
          # As body is a multiform containing unique IDs, sanitize it before checking content
          expect(parse_multiform(request.body)).to eq [
            ['Content-Disposition: form-data; name="path"', '/dbfs/path/to/file'],
            ['Content-Disposition: form-data; name="contents"; filename="example_file"', 'Content-Type: text/plain', 'Hello world!'],
            ['Content-Disposition: form-data; name="overwrite"', 'true']
          ]
        end.
        to_return(body: '')
      expect { chef_run }.not_to raise_error
    end

  end

end
