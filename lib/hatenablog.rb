#!/usr/bin/env ruby
# coding: utf-8

require 'rexml/document'
require 'oauth'

require 'blog_entry'
require 'blog_feed'
require 'configuration'

class Hatenablog
  DEFAULT_CONFIG_PATH = './config.yml'

  COLLECTION_URI = "https://blog.hatena.ne.jp/%s/%s/atom/entry"
  MEMBER_URI     = "https://blog.hatena.ne.jp/%s/%s/atom/entry/%s"
  CATEGORY_URI   = "https://blog.hatena.ne.jp/%s/%s/atom/category"

  attr_writer :access_token

  def self.create(config_file = DEFAULT_CONFIG_PATH)
    config = Configuration.new(config_file)
    blog = Hatenablog.new(config.consumer_key, config.consumer_secret,
                          config.access_token, config.access_token_secret,
                          config.user_id, config.blog_id)
    return blog unless block_given?
    yield blog
  end

  def entries(page = 0)
    next_page_uri = collection_uri
    current_page = 0
    entries = []
    while current_page <= page
      feed = BlogFeed.load_xml(get_collection(next_page_uri).body)
      entries += feed.entries

      break unless feed.has_next?
      next_page_uri = feed.next_uri
      current_page += 1
    end
    entries
  end

  def categories
    categories_doc = REXML::Document.new(get_category_doc.body)
    categories_list = []
    categories_doc.elements.each('//atom:category') do |cat|
      categories_list << cat.attribute('term').to_s
    end
    categories_list
  end

  def get_entry(entry_id)
    response = get(member_uri(entry_id: entry_id))
    BlogEntry.load_xml(response.body)
  end

  def post_entry(title = '', content = '', categories = [], draft = 'no')
    entry_xml = entry_xml(title, content, categories, draft)
    response = post(entry_xml: entry_xml)
    BlogEntry.load_xml(response.body)
  end

  def update_entry(entry_id, title = '', content = '', categories = [], draft = 'no')
    entry_xml = entry_xml(title, content, categories, draft)
    response = put(member_uri(entry_id: entry_id), entry_xml)
    BlogEntry.load_xml(response.body)
  end

  def delete_entry(entry_id)
    delete(member_uri(entry_id: entry_id))
  end

  def collection_uri(user_id = @user_id, blog_id = @blog_id)
    COLLECTION_URI % [user_id, blog_id]
  end

  def member_uri(user_id = @user_id, blog_id = @blog_id, entry_id: '')
    MEMBER_URI % [user_id, blog_id, entry_id]
  end

  def category_doc_uri(user_id = @user_id, blog_id = @blog_id)
    CATEGORY_URI % [user_id, blog_id]
  end

  def entry_xml(title = '', content = '', categories = [], draft = 'no', author_name = @user_id)
    xml = <<XML
<?xml version="1.0" encoding="utf-8"?>
<entry xmlns="http://www.w3.org/2005/Atom"
       xmlns:app="http://www.w3.org/2007/app">
  <title>%s</title>
  <author><name>%s</name></author>
  <content type="text/x-markdown">%s</content>
  %s
  <app:control>
    <app:draft>%s</app:draft>
  </app:control>
</entry>
XML

    categories_tag = categories.inject('') do |s, c|
      s + "<category term=\"#{c}\" />\n"
    end
    xml % [title, author_name, content, categories_tag, draft]
  end


  private

  def initialize(consumer_key, consumer_secret, access_token, access_token_secret,
                 user_id, blog_id)
    consumer = OAuth::Consumer.new(consumer_key, consumer_secret)
    @access_token = OAuthAccessToken.new(OAuth::AccessToken.new(consumer,
                                                                access_token,
                                                                access_token_secret))

    @user_id = user_id
    @blog_id = blog_id
  end


  def get(uri)
    @access_token.get(uri)
  end

  def get_collection(uri = collection_uri)
    unless uri.include?(collection_uri)
      raise ArgumentError.new('Invalid collection URI: ' + uri)
    end
    get(uri)
  end

  def get_category_doc
    get(category_doc_uri)
  end

  def post(uri = collection_uri, entry_xml: '')
    @access_token.post(uri, entry_xml)
  end

  def put(uri, entry_xml)
    @access_token.put(uri, entry_xml)
  end

  def delete(uri)
    @access_token.delete(uri)
  end
end

class OAuthAccessToken
  def initialize(access_token)
    @access_token = access_token
  end

  def get(uri)
    begin
      response = @access_token.get(uri)
    rescue => problem
      raise 'Fail to GET: ' + problem.request.body
    end
    response
  end

  def post(uri,
           body = '',
           headers = { 'Content-Type' => 'application/atom+xml; type=entry' } )
    begin
      response = @access_token.post(uri, body, headers)
    rescue => problem
      raise 'Fail to POST: ' + problem.request.body
    end
    response
  end

  def put(uri,
          body = '',
          headers = { 'Content-Type' => 'application/atom+xml; type=entry' } )
    begin
      response = @access_token.put(uri, body, headers)
    rescue => problem
      raise 'Fail to PUT: ' + problem.request.body
    end
    response
  end

  def delete(uri,
             headers = { 'Content-Type' => 'application/atom+xml; type=entry' })
    begin
      response = @access_token.delete(uri, headers)
    rescue => problem
      raise 'Fail to DELETE: ' + problem.request.body
    end
    response
  end
end
