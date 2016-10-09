require 'net/http'
require 'oauth'

module Hatenablog
  module Requester
    class RequestError < StandardError; end

    def self.create(config)
      if config.auth_type == 'basic'
        Requester::Basic.new(config.user_id, config.api_key)
      else
        consumer = ::OAuth::Consumer.new(config.consumer_key, config.consumer_secret)
        Requester::OAuth.new(::OAuth::AccessToken.new(consumer, config.access_token, config.access_token_secret))
      end
    end

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

    class Basic
      METHODS = {
        get: Net::HTTP::Get,
        post: Net::HTTP::Post,
        put: Net::HTTP::Put,
        delete: Net::HTTP::Delete
      }

      # Create a new Basic authentication requester.
      # @params [string] user_id Hatena user ID
      # @params [string] api_key Hatena API key
      def initialize(user_id, api_key)
        @user_id = user_id
        @api_key = api_key
      end

      # HTTP GET method
      # @param [string] uri target URI
      # @return [Net::HTTPResponse] HTTP response
      def get(uri)
        request(uri, :get)
      end

      # HTTP POST method
      # @param [string] uri target URI
      # @param [string] body HTTP request body
      # @param [string] headers HTTP request headers
      # @return [Net::HTTPResponse] HTTP response
      def post(uri, body, headers = nil)
        request(uri, :post, body: body, headers: headers)
      end

      # HTTP PUT method
      # @param [string] uri target URI
      # @param [string] body HTTP request body
      # @param [string] headers HTTP request headers
      # @return [Net::HTTPResponse] HTTP response
      def put(uri, body, headers = nil )
        request(uri, :put, body: body, headers: headers)
      end

      # HTTP DELETE method
      # @param [string] uri target URI
      # @param [string] headers HTTP request headers
      # @return [Net::HTTPResponse] HTTP response
      def delete(uri, headers = nil)
        request(uri, :delete, headers: headers)
      end

      private
      def request(uri, method, body: nil, headers: nil)
        uri = URI(uri)
        req = METHODS[method].new(uri, headers)
        req.basic_auth @user_id, @api_key
        if body
          req.body = body
          req.content_type = 'application/atom+xml; type=entry'
        end

        http = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.port == 443)
        http.request(req)
      rescue => problem
        raise RequestError, "Fail to #{method.upcase}: " + problem.to_s
      end
    end
  end
end
