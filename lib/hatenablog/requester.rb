require 'net/http'
require 'oauth'

module Hatenablog
  module Requester
    ATOM_CONTENT_TYPE = 'application/atom+xml; type=entry'.freeze
    DEFAULT_HEADER = { 'Content-Type' => ATOM_CONTENT_TYPE }

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
        request(:get, uri)
      end

      # HTTP POST method
      # @param [string] uri target URI
      # @param [string] body HTTP request body
      # @param [string] headers HTTP request headers
      # @return [Net::HTTPResponse] HTTP response
      def post(uri, body = '', headers = DEFAULT_HEADER)
        request(:post, uri, body: body, headers: headers)
      end

      # HTTP PUT method
      # @param [string] uri target URI
      # @param [string] body HTTP request body
      # @param [string] headers HTTP request headers
      # @return [Net::HTTPResponse] HTTP response
      def put(uri, body = '', headers = DEFAULT_HEADER)
        request(:put, uri, body: body, headers: headers)
      end

      # HTTP DELETE method
      # @param [string] uri target URI
      # @param [string] headers HTTP request headers
      # @return [Net::HTTPResponse] HTTP response
      def delete(uri, headers = DEFAULT_HEADER)
        request(:delete, uri, headers: headers)
      end

      private

      def request(method, uri, body: nil, headers: nil)
        begin
          @access_token.send(method, *[uri, body, headers].compact)
        rescue => problem
          raise RequestError, "Fail to #{method.upcase}: " + problem.to_s
        end
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
      def post(uri, body, headers = {})
        request(uri, :post, body: body, headers: headers)
      end

      # HTTP PUT method
      # @param [string] uri target URI
      # @param [string] body HTTP request body
      # @param [string] headers HTTP request headers
      # @return [Net::HTTPResponse] HTTP response
      def put(uri, body, headers = {})
        request(uri, :put, body: body, headers: headers)
      end

      # HTTP DELETE method
      # @param [string] uri target URI
      # @param [string] headers HTTP request headers
      # @return [Net::HTTPResponse] HTTP response
      def delete(uri, headers = {})
        request(uri, :delete, headers: headers)
      end

      private

      def request(uri, method, body: nil, headers: {})
        uri = URI(uri)
        req = METHODS[method].new(uri.to_s, headers)
        req.basic_auth @user_id, @api_key
        if body
          req.body = body
          req.content_type = ATOM_CONTENT_TYPE
        end

        http = Net::HTTP.new(uri.hostname, uri.port)
        http.use_ssl = uri.port == 443
        http.start do |conn|
          conn.request(req)
        end
        
      rescue => problem
        raise RequestError, "Fail to #{method.upcase}: " + problem.to_s
      end
    end
  end
end
