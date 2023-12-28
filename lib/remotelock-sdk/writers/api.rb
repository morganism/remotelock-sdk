# frozen_string_literal: true

require_relative 'core'
require_relative '../core/api_caller'

module RemoteLock
  module Writer
    #
    # Send points direct to RemoteLock's API. This requires an
    # endpoint, a token, and HTTPS egress.
    #
    class Api < Core
      def open
        @conn = RemoteLock::ApiCaller.new(self, creds, opts)
      end

      def api_path
        '/report'
      end

      def validate_credentials(creds)
        unless creds.key?(:endpoint) && creds[:endpoint]
          raise(RemoteLock::Exception::CredentialError,
                'credentials must contain API endpoint')
        end

        return true if creds.key?(:token) && creds[:token]

        raise(RemoteLock::Exception::CredentialError,
              'credentials must contain API token')
      end

      def send_point(body)
        _send_point(body)
        summary.sent += body.size
        true
      rescue StandardError => e
        summary.unsent += body.size
        logger.log('WARNING: failed to send point(s).')
        logger.log(e.to_s, :debug)
        false
      end

      private

      def write_loop(points)
        body = points.map do |p|
          p[:ts] = p[:ts].to_i if p[:ts].is_a?(Time)
          hash_to_wf(p)
        end

        send_point(body)
      end

      # Send points in batches of a hundred. I'm not sure exactly
      # how much the API can cope with in a single call, so this
      # might change.
      #
      def _send_point(body)
        body.each_slice(100) do |p|
          conn.post('/?f=remotelock', p.join("\n"), 'application/octet-stream')
        end
      end
    end
  end
end
