# frozen_string_literal: true

# Requires Ruby with test-unit and faraday gems.
# ruby client_test.rb

require 'faraday'
require 'json'
require 'test/unit'

# Example API client
class Client
  def initialize(conn)
    @conn = conn
  end
end
