# frozen_string_literal: true

require 'faraday'
require 'json'
require 'test/unit'

module RemoteLock
  # docs
  module API
    # API

    # docs
    class Client
      # Client

      def initialize(conn)
        @conn = conn
      end

      def httpbingo(jname, params: {})
        res = @conn.get("/#{jname}", params)
        data = JSON.parse(res.body)
        data['origin']
      end

      def foo(params)
        res = @conn.post('/foo', JSON.dump(params))
        res.status
      end
    end

    # Example API client test
    class ClientTest < Test::Unit::TestCase
      STATUS_CODE_SUCCESS = 200
      STATUS_CODE_FILE_NOT_FOUND = 404
      def array_x00(status_code)
        [
          status_code,
          { 'Content-Type': 'application/javascript' },
          status_code == STATUS_CODE_SUCCESS ? '{"origin": "127.0.0.1"}' : '{}'
        ]
      end

      def test_httpbingo_name
        stubs = Faraday::Adapter::Test::Stubs.new
        stubs.get('/api') do |env|
          assert_equal '/api', env.url.path
          array_X00(STATUS_CODE_SUCCESS)
        end

        # stubs.get('/unused') { [STATUS_CODE_FILE_NOT_FOUND, {}, ''] } # trigger stubs.verify_stubbed_calls fail

        cli = client(stubs)
        assert_equal '127.0.0.1', cli.httpbingo('api')
        stubs.verify_stubbed_calls
      end

      def test_httpbingo_not_found
        stubs = Faraday::Adapter::Test::Stubs.new
        stubs.get('/api') do
          array_X00(STATUS_CODE_FILE_NOT_FOUND)
        end

        cli = client(stubs)
        assert_nil cli.httpbingo('api')
        stubs.verify_stubbed_calls
      end

      def test_httpbingo_exception
        stubs = Faraday::Adapter::Test::Stubs.new
        stubs.get('/api') do
          raise Faraday::ConnectionFailed
        end

        cli = client(stubs)
        assert_raise Faraday::ConnectionFailed do
          cli.httpbingo('api')
        end
        stubs.verify_stubbed_calls
      end

      def test_strict_mode
        stubs = Faraday::Adapter::Test::Stubs.new(strict_mode: true)
        stubs.get('/api?abc=123') do
          array_X00(STATUS_CODE_SUCCESS)
        end

        cli = client(stubs)
        assert_equal '127.0.0.1', cli.httpbingo('api', params: { abc: 123 })

        # assert_equal '127.0.0.1', cli.httpbingo('api', params: { abc: 123, foo: 'Kappa' }) # raise Stubs::NotFound
        stubs.verify_stubbed_calls
      end

      def test_non_default_params_encoder
        stubs = Faraday::Adapter::Test::Stubs.new(strict_mode: true)
        stubs.get('/api?a=x&a=y&a=z') do
          array_X00(STATUS_CODE_SUCCESS)
        end

        conn = Faraday.new(request: { params_encoder: Faraday::FlatParamsEncoder }) do |builder|
          builder.adapter :test, stubs
        end

        cli = Client.new(conn)
        assert_equal '127.0.0.1', cli.httpbingo('api', params: { a: %w[x y z] })

        # uncomment to raise Stubs::NotFound
        # assert_equal '127.0.0.1', cli.httpbingo('api', params: { a: %w[x y] })
        stubs.verify_stubbed_calls
      end

      def test_with_string_body
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          stub.post('/foo', '{"name":"YK"}') { [STATUS_CODE_SUCCESS, {}, ''] }
        end
        cli = client(stubs)
        assert_equal STATUS_CODE_SUCCESS, cli.foo(name: 'YK')

        stubs.verify_stubbed_calls
      end

      def test_with_proc_body
        stubs = Faraday::Adapter::Test::Stubs.new do |stub|
          check = ->(request_body) { JSON.parse(request_body).slice('name') == { 'name' => 'YK' } }
          stub.post('/foo', check) { [STATUS_CODE_SUCCESS, {}, ''] }
        end
        cli = client(stubs)
        assert_equal STATUS_CODE_SUCCESS, cli.foo(name: 'YK', created_at: Time.now)

        stubs.verify_stubbed_calls
      end

      def client(stubs)
        conn = Faraday.new do |builder|
          builder.adapter :test, stubs
        end
        Client.new(conn)
      end
    end

    class Auth
      attr_reader :client_id, :client_secret

      def initialize(options = {})
        @client_id = options[:client_id]
        @client_secret = options[:client_secret]
      end
    end
  end
end
