require 'hatenablog/category'
require 'hatenablog/entry'
require 'hatenablog/feed'
require 'hatenablog/configuration'
require 'hatenablog/requester'

module Hatenablog
  class Client
    DEFAULT_CONFIG_PATH = './config.yml'.freeze

    COLLECTION_URI = "https://blog.hatena.ne.jp/%s/%s/atom/entry".freeze
    MEMBER_URI     = "https://blog.hatena.ne.jp/%s/%s/atom/entry/%s".freeze
    CATEGORY_URI   = "https://blog.hatena.ne.jp/%s/%s/atom/category".freeze

    attr_writer :requester

    # Create a new hatenablog AtomPub client from a configuration file.
    # @param [String] config_file configuration file path
    # @return [Hatenablog::Client] created hatenablog client
    def self.create(config_file = DEFAULT_CONFIG_PATH)
      config = Configuration.create(config_file)
      blog = Hatenablog::Client.new(config)
      return blog unless block_given?
      yield blog
    end

    # Get a blog title.
    # @return [String] blog title
    def title
      feed = Feed.load_xml(get_collection(collection_uri).body)
      feed.title
    end

    # Get a author name.
    # @return [String] blog author name
    def author_name
      feed = Feed.load_xml(get_collection(collection_uri).body)
      feed.author_name
    end

    # Get a enumerator of blog entries.
    # @param [Fixnum] page page number to get
    # @return [Hatenablog::Entries] enumerator of blog entries
    def entries(page = 0)
      raise ArgumentError.new('page must be non-negative') if page < 0
      Entries.new(self, page)
    end

    # Get all blog entries.
    # @return [Hatenablog::Entries] enumerator of blog entries
    def all_entries
      Entries.new(self, nil)
    end

    # Get the next feed of the given feed.
    # Return the first feed if no argument is passed.
    # @param [Hatenablog::Feed] feed blog feed
    # @return [Hatenablog::Feed] next blog feed
    def next_feed(feed = nil)
      return Feed.load_xml(get_collection(collection_uri).body) if feed.nil?
      return nil unless feed.has_next?
      Feed.load_xml(get_collection(feed.next_uri).body)
    end

    # Get blog categories array.
    # @return [Array] blog categories
    def categories
      categories_doc = Category.new(get_category_doc.body)
      categories_doc.categories
    end

    # Get a blog entry specified by its ID.
    # @param [String] entry_id entry ID
    # @return [Hatenablog::BlogEntry] entry
    def get_entry(entry_id)
      response = get(member_uri(entry_id))
      Entry.load_xml(response.body)
    end

    # Post a blog entry.
    # @param [String] title entry title
    # @param [String] content entry content
    # @param [Array] categories entry categories
    # @param [String] draft this entry is draft if 'yes', otherwise it is not draft
    # @return [Hatenablog::BlogEntry] posted entry
    def post_entry(title = '', content = '', categories = [], draft = 'no')
      entry_xml = entry_xml(title, content, categories, draft)
      response = post(entry_xml)
      Entry.load_xml(response.body)
    end

    # Update a blog entry specified by its ID.
    # @param [String] entry_id updated entry ID
    # @param [String] title entry title
    # @param [String] content entry content
    # @param [Array] categories entry categories
    # @param [String] draft this entry is draft if 'yes', otherwise it is not draft
    # @param [String] updated entry updated datetime (ISO 8601)
    # @return [Hatenablog::BlogEntry] updated entry
    def update_entry(entry_id, title = '', content = '', categories = [], draft = 'no', updated = '')
      entry_xml = entry_xml(title, content, categories, draft, updated)
      response = put(entry_xml, member_uri(entry_id))
      Entry.load_xml(response.body)
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
    # @param [String] updated entry updated datetime (ISO 8601)
    # @param [String] author_name entry author name
    # @return [String] XML string
    def entry_xml(title = '', content = '', categories = [], draft = 'no', updated = '', author_name = @user_id)
      builder = Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
        xml.entry('xmlns'     => 'http://www.w3.org/2005/Atom',
                  'xmlns:app' => 'http://www.w3.org/2007/app') do
          xml.title title
          xml.author do
            xml.name author_name
          end
          xml.content(content, type: 'text/x-markdown')
          xml.updated updated unless updated.empty? || updated.nil?
          categories.each do |category|
            xml.category(term: category)
          end
          xml['app'].control do
            xml['app'].draft draft
          end
        end
      end

      builder.to_xml
    end


    private

    def initialize(config)
      @requester = Requester.create(config)
      @user_id = config.user_id
      @blog_id = config.blog_id
    end

    def get(uri)
      @requester.get(uri)
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
      @requester.post(uri, entry_xml)
    end

    def put(entry_xml, uri)
      @requester.put(uri, entry_xml)
    end

    def delete(uri)
      @requester.delete(uri)
    end
  end

  class Entries
    include Enumerable

    def initialize(client, page = 0)
      @client = client
      @page = page
    end

    def each
      current_page = 0
      until (@page && current_page > @page) || !(feed = @client.next_feed(feed))
        feed.entries.each { |entry| yield entry }
        current_page += 1
      end
    end
  end
end
