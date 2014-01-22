require 'yaml'
require 'net/http'
require 'uri'

env = ENV['RACK_ENV']

$stderr.puts "Committing routes for `#{env}`."

def load_yaml(name)
  YAML.load(File.read('./'+name+'.yml'))
end

router_api_url = load_yaml('router-api')[env]['url']
api = URI(router_api_url)
http = Net::HTTP.new api.host, api.port

response = http.post(router_api_url + '/routes/commit', "")
if response.code != '200'
  $stderr.puts "Problem Committing routes. \n #{response.inspect}"
  exit -1
end

$stderr.puts "Succesfully committed all routes."
