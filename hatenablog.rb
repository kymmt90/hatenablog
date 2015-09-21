#!/usr/bin/env ruby
# coding: utf-8

require 'rexml/document'
require 'oauth'

require './configuration'

module Hatena
  class HatenaBlog
    DEFAULT_CONFIG_PATH = './hateblo4ruby.yml'

    COLLECTION_URI = "https://blog.hatena.ne.jp/%s/%s/atom/entry"
    CATEGORY_URI   = "https://blog.hatena.ne.jp/%s/%s/atom/category"

    def self.create(config_file = DEFAULT_CONFIG_PATH)
      config = Hatena::Configuration.new(config_file)
      Hatena::HatenaBlog.new(config.consumer_key, config.consumer_secret,
                             config.access_token, config.access_token_secret,
                             config.user_id, config.blog_id)
    end

    def entries(page = 0)
      next_page_uri = collection_uri
      current_page = 0
      contents = ""
      while current_page <= page
        feed = REXML::Document.new(get_collection(next_page_uri).body)
        contents += feed.get_elements('//entry').inject('') do |s, e|
          s + e.to_s
        end

        break if feed.elements["//link[@rel='next']"].nil?
        next_page_uri = feed.elements["//link[@rel='next']"].attribute('href').to_s
        current_page += 1
      end
      contents
    end

    def categories
      categories_doc = REXML::Document.new(get_category_doc.body)
      categories_list = []
      categories_doc.elements.each('//atom:category') do |cat|
        categories_list << cat.attribute('term').to_s
      end
      categories_list
    end


    private

      def initialize(consumer_key, consumer_secret, access_token, access_token_secret,
                     user_id, blog_id)
        @consumer = OAuth::Consumer.new(consumer_key, consumer_secret)
        @access_token = OAuth::AccessToken.new(@consumer, access_token, access_token_secret)
        @user_id = user_id
        @blog_id = blog_id
      end

      def request(method, uri)
        begin
          response = @access_token.request(method, uri)
        rescue => problem
          raise 'Fail to request: ' + problem.request.body
        end
        response
      end

      def get_collection(uri = collection_uri)
        unless uri.include?(collection_uri)
          raise ArgumentError.new('Invalid collection URI: ' + uri)
        end
        request(:get, uri)
      end

      def get_category_doc
        request(:get, category_doc_uri)
      end

      def collection_uri(user_id = @user_id, blog_id = @blog_id)
        COLLECTION_URI % [user_id, blog_id]
      end

      def category_doc_uri(user_id = @user_id, blog_id = @blog_id)
        CATEGORY_URI % [user_id, blog_id]
      end
  end
end
