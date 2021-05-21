# See http://docs.chef.io/workstation/config_rb/ for more information on knife configuration options

log_level                :info
log_location             STDOUT
node_name                'muriel_salvan'
client_key               "#{__dir__}/supermarket.pem"
chef_server_url          'https://api.chef.io/organizations/x-aeon'
