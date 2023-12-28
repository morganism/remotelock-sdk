# frozen_string_literal: true

require 'json'
require 'net/http'

uri = URI('https://eo9cqqcowp70t6o.m.pipedream.net')
req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')

req.body = {
  'test': 'event'
}.to_json

Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
  http.request(req)
end
