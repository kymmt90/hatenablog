module Hatenablog
  module Requester
    class RequestError < StandardError; end

    class OAuth
      # Create a new OAuth 1.0a access token.
      # @param [OAuth::AccessToken] access_token access token object
      def initialize(access_token)
        @access_token = access_token
      end

      # HTTP GET method
      # @param [string] uri target URI
      # @return [Net::HTTPResponse] HTTP response
      def get(uri)
        begin
          response = @access_token.get(uri)
        rescue => problem
          raise RequestError, 'Fail to GET: ' + problem.to_s
        end
        response
      end

      # HTTP POST method
      # @param [string] uri target URI
      # @param [string] body HTTP request body
      # @param [string] headers HTTP request headers
      # @return [Net::HTTPResponse] HTTP response
      def post(uri,
               body = '',
               headers = { 'Content-Type' => 'application/atom+xml; type=entry' } )
        begin
          response = @access_token.post(uri, body, headers)
        rescue => problem
          raise RequestError, 'Fail to POST: ' + problem.to_s
        end
        response
      end

      # HTTP PUT method
      # @param [string] uri target URI
      # @param [string] body HTTP request body
      # @param [string] headers HTTP request headers
      # @return [Net::HTTPResponse] HTTP response
      def put(uri,
              body = '',
              headers = { 'Content-Type' => 'application/atom+xml; type=entry' } )
        begin
          response = @access_token.put(uri, body, headers)
        rescue => problem
          raise RequestError, 'Fail to PUT: ' + problem.to_s
        end
        response
      end

      # HTTP DELETE method
      # @param [string] uri target URI
      # @param [string] headers HTTP request headers
      # @return [Net::HTTPResponse] HTTP response
      def delete(uri,
                 headers = { 'Content-Type' => 'application/atom+xml; type=entry' })
        begin
          response = @access_token.delete(uri, headers)
        rescue => problem
          raise RequestError, 'Fail to DELETE: ' + problem.to_s
        end
        response
      end
    end
  end
end
