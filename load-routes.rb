require 'yaml'
require 'net/http'
require 'uri'
require 'json'

env = ENV['RACK_ENV']

$stderr.puts "Loading routes for `#{env}`."

def load_yaml(name)
  YAML.load(File.read('./'+name+'.yml'))
end

backends = load_yaml('backends')[env]
round_robins = load_yaml('round_robins')[env]
routes = load_yaml('routes')

backends_by_id = [backends|round_robins].flatten.inject({}){|memo, backend| memo[backend['id']] = backend; memo }

routes.each do |route|
  if backends_by_id[route['backend_id']].nil?
    raise "backend_id #{route['backend_id']} not found for #{route.inspect}"
  end
end

@router_api_url = load_yaml('router-api')[env]['url']
api = URI(@router_api_url)
@http = Net::HTTP.new api.host, api.port

def submit(subpath, data)
  @http.put(@router_api_url + subpath, JSON.dump(data), 'Content-Type'=>'application/json')
end

all_backends = {
  '/backends/' => backends,
  '/round_robins/' => round_robins
}

all_backends.each_pair do |url, backends|
  backends.each do |backend|
    response = submit(url+backend['id'], backend: backend)
    if !response.code.start_with?('20')
      $stderr.puts "Problem upserting backend. #{backend}.\n #{response.inspect} \n #{response.body rescue nil}"
      exit -1
    end
  end
end

routes.each do |route|
  response = submit('/routes', route)
  if !response.code.start_with?('20')
    $stderr.puts "Problem upserting route. #{route}.\n #{response.inspect} \n #{response.body rescue nil}"
    exit -1
  end
end

$stderr.puts "Succesfully upserted all routes. Run commit.rb to enable new routing table:"
$stderr.puts "  #{@router_api_url}/routes/all"
$stderr.puts "  #{@router_api_url}/backends/all"
