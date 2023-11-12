# frozen_string_literal: true

require_relative 'core'

module RemoteLock
  module Writer
    #
    # Everything specific to writing points to a RemoteLock proxy, in
    # native RemoteLock format, to a socket. (The original and,
    # once, only way to send points.)
    #
    class Proxy < Core
      # Open a connection to a socket to a RemoteLock proxy, putting the
      # descriptor in instance variable @conn.
      # @return [TCPSocket]
      #
      def open
        if opts[:noop]
          logger.log('No-op requested. Not opening connection to proxy.')
          return true
        end

        port = creds[:port] || default_port
        logger.log("Connecting to #{creds[:proxy]}:#{port}.", :debug)
        open_socket(creds[:proxy], port)
      end

      # Close the connection described by the @conn instance variable.
      #
      def close
        return if opts[:noop]

        logger.log('Closing connection to proxy.', :debug)
        conn.close
      end

      def validate_credentials(creds)
        return true if creds.key?(:proxy) && creds[:proxy]

        raise(RemoteLock::Exception::CredentialError,
              'credentials must contain proxy address')
      end

      private

      def open_socket(proxy, port)
        @conn = TCPSocket.new(proxy, port)
      rescue StandardError => e
        logger.log(e, :error)
        raise RemoteLock::Exception::InvalidEndpoint
      end

      # @param point [String] point or points in native RemoteLock format.
      # @raise [SocketError] if point cannot be written
      #
      def _send_point(point)
        return if opts[:noop]

        conn.puts(point)
      rescue StandardError
        raise RemoteLock::Exception::SocketError
      end

      # return [Integer] the port to connect to, if none is supplied
      #
      def default_port
        2878
      end
    end
  end
end
