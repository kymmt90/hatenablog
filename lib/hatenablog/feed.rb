require 'nokogiri'
require 'time'

require 'hatenablog/entry'

module Hatenablog
  class Feed
    # @dynamic uri, next_uri, title, author_name, updated
    attr_reader :uri, :next_uri, :title, :author_name, :updated

    # Create a new blog feed from a XML string.
    # @param [String] xml XML string representation
    # @return [Hatenablog::Feed]
    def self.load_xml(xml)
      Hatenablog::Feed.new(xml)
    end

    # @return [Array]
    def entries
      @entries.dup
    end

    def each_entry
      @entries.each do |entry|
        yield entry
      end
    end

    # Return true if this feed has next feed.
    # @return [Boolean]
    def has_next?
      @next_uri != ''
    end


    private

    def initialize(xml)
      @document = Nokogiri::XML(xml)
      parse_document
    end

    def parse_document
      @uri         = @document.at_css("feed link[@rel='alternate']")['href'].to_s
      @next_uri    = if @document.css("feed link[@rel='next']").empty?
                       ''
                     else
                       @document.at_css("feed link[@rel='next']")['href'].to_s
                     end
      @title       = @document.at_css('feed title').content
      @author_name = @document.at_css('author name').content
      @updated     = Time.parse(@document.at_css('feed updated').content)
      parse_entry
    end

    def parse_entry
      @entries = @document.css('feed > entry').inject(Array.new) do |entries, entry|
        # add namespace 'app' to recognize XML correctly
        entry['xmlns:app'] = 'http://www.w3.org/2007/app'
        entries << Hatenablog::Entry.load_xml(entry.to_s)
      end
    end
  end
end
