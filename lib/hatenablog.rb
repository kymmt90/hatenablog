require 'oauth'

require 'blog_category'
require 'blog_entry'
require 'blog_feed'
require 'configuration'

class Hatenablog
  DEFAULT_CONFIG_PATH = './config.yml'.freeze

  COLLECTION_URI = "https://blog.hatena.ne.jp/%s/%s/atom/entry".freeze
  MEMBER_URI     = "https://blog.hatena.ne.jp/%s/%s/atom/entry/%s".freeze
  CATEGORY_URI   = "https://blog.hatena.ne.jp/%s/%s/atom/category".freeze

  attr_writer :access_token

  # Create a new hatenablog AtomPub client from a configuration file.
  # @param [String] config_file configuration file path
  # @return [Hatenablog] created hatenablog client
  def self.create(config_file = DEFAULT_CONFIG_PATH)
    config = Configuration.new(config_file)
    blog = Hatenablog.new(config.consumer_key, config.consumer_secret,
                          config.access_token, config.access_token_secret,
                          config.user_id, config.blog_id)
    return blog unless block_given?
    yield blog
  end

  # Get a blog title.
  # @return [String] blog title
  def title
    feed = BlogFeed.load_xml(get_collection(collection_uri).body)
    feed.title
  end

  # Get a author name.
  # @return [String] blog author name
  def author_name
    feed = BlogFeed.load_xml(get_collection(collection_uri).body)
    feed.author_name
  end

  # Get blog entries array.
  # @param [Fixnum] page page number to get
  # @return [Array] blog entries
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

  # Get blog categories array.
  # @return [Array] blog categories
  def categories
    categories_doc = BlogCategory.new(get_category_doc.body)
    categories_doc.categories
  end

  # Get a blog entry specified by its ID.
  # @param [String] entry_id entry ID
  # @return [BlogEntry] entry
  def get_entry(entry_id)
    response = get(member_uri(entry_id))
    BlogEntry.load_xml(response.body)
  end

  # Post a blog entry.
  # @param [String] title entry title
  # @param [String] content entry content
  # @param [Array] categories entry categories
  # @param [String] draft this entry is draft if 'yes', otherwise it is not draft
  # @return [BlogEntry] posted entry
  def post_entry(title = '', content = '', categories = [], draft = 'no')
    entry_xml = entry_xml(title, content, categories, draft)
    response = post(entry_xml)
    BlogEntry.load_xml(response.body)
  end

  # Update a blog entry specified by its ID.
  # @param [String] entry_id updated entry ID
  # @param [String] title entry title
  # @param [String] content entry content
  # @param [Array] categories entry categories
  # @param [String] draft this entry is draft if 'yes', otherwise it is not draft
  # @return [BlogEntry] updated entry
  def update_entry(entry_id, title = '', content = '', categories = [], draft = 'no')
    entry_xml = entry_xml(title, content, categories, draft)
    response = put(entry_xml, member_uri(entry_id))
    BlogEntry.load_xml(response.body)
  end

  # Delete a blog entry specified by its ID.
  # @param [String] entry_id deleted entry ID
  def delete_entry(entry_id)
    delete(member_uri(entry_id))
  end

  # Get Hatenablog AtomPub collection URI.
  # @param [String] user_id Hatena user ID
  # @param [String] blog_id Hatenablog ID
  # @return [String] Hatenablog AtomPub collection URI
  def collection_uri(user_id = @user_id, blog_id = @blog_id)
    COLLECTION_URI % [user_id, blog_id]
  end

  # Get Hatenablog AtomPub member URI.
  # @param [String] entry_id entry ID
  # @param [String] user_id Hatena user ID
  # @param [String] blog_id Hatenablog ID
  # @return [String] Hatenablog AtomPub member URI
  def member_uri(entry_id, user_id = @user_id, blog_id = @blog_id)
    MEMBER_URI % [user_id, blog_id, entry_id]
  end

  # Get Hatenablog AtomPub category document URI.
  # @param [String] user_id Hatena user ID
  # @param [String] blog_id Hatenablog ID
  # @return [String] Hatenablog AtomPub category document URI
  def category_doc_uri(user_id = @user_id, blog_id = @blog_id)
    CATEGORY_URI % [user_id, blog_id]
  end

  # Build a entry XML from arguments.
  # @param [String] title entry title
  # @param [String] content entry content
  # @param [Array] categories entry categories
  # @param [String] draft this entry is draft if 'yes', otherwise it is not draft
  # @param [String] author_name entry author name
  # @return [String] XML string
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

  def post(entry_xml, uri = collection_uri)
    @access_token.post(uri, entry_xml)
  end

  def put(entry_xml, uri)
    @access_token.put(uri, entry_xml)
  end

  def delete(uri)
    @access_token.delete(uri)
  end
end

class OAuthAccessToken

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
      raise OAuthError, 'Fail to GET: ' + problem.to_s
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
      raise OAuthError, 'Fail to POST: ' + problem.to_s
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
      raise OAuthError, 'Fail to PUT: ' + problem.to_s
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
      raise OAuthError, 'Fail to DELETE: ' + problem.to_s
    end
    response
  end
end

class OAuthError < StandardError; end
