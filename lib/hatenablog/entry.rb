require 'nokogiri'

module Hatenablog
  class Entry
    attr_reader :uri, :edit_uri, :id, :author_name, :title, :content, :updated

    # Create a new blog entry from a XML string.
    # @param [String] xml XML string representation
    # @return [Hatenablog::Entry]
    def self.load_xml(xml)
      Hatenablog::Entry.new(xml)
    end

    # Create a new blog entry from arguments.
    # @param [String] uri entry URI
    # @param [String] edit_uri entry URI for editing
    # @param [String] author_name entry author name
    # @param [String] title entry title
    # @param [String] content entry content
    # @param [String] draft this entry is draft if 'yes', otherwise it is not draft
    # @param [Array] categories categories array
    # @param [String] updated entry updated datetime (ISO 8601)
    # @return [Hatenablog::Entry]
    def self.create(uri: '', edit_uri: '', author_name: '', title: '',
                    content: '', draft: 'no', categories: [], updated: '')
      Hatenablog::Entry.new(self.build_xml(uri, edit_uri, author_name, title,
                            content, draft, categories, updated))
    end

    # @return [Boolean]
    def draft?
      @draft == 'yes'
    end

    # @return [Array]
    def categories
      @categories.dup
    end

    def each_category
      @categories.each do |category|
        yield category
      end
    end

    # @return [String]
    def to_xml
      @document.to_s.gsub(/\"/, "'")
    end


    private

    def self.build_xml(uri, edit_uri, author_name, title, content, draft, categories, updated)
      builder = Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
        xml.entry('xmlns'     => 'http://www.w3.org/2005/Atom',
                  'xmlns:app' => 'http://www.w3.org/2007/app') do
          xml.link(href: edit_uri, rel: 'edit')
          xml.link(href: uri,      rel: 'alternate', type: 'text/html')
          xml.author do
            xml.name author_name
          end
          xml.title title
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

    def initialize(xml)
      @document = Nokogiri::XML(xml)
      parse_document
    end

    def parse_document
      @uri         = @document.at_css('link[@rel="alternate"]')['href'].to_s
      @edit_uri    = @document.at_css('link[@rel="edit"]')['href'].to_s
      @id          = @edit_uri.split('/').last
      @author_name = @document.at_css('author name').content
      @title       = @document.at_css('title').content
      @content     = @document.at_css('content').content
      @draft       = @document.at_css('entry app|control app|draft').content
      @categories  = parse_categories
      unless @document.at_css('entry updated').nil?
        @updated = Time.parse(@document.at_css('entry updated').content)
      end
    end

    def parse_categories
      categories = @document.css('category').inject([]) do |categories, category|
        categories << category['term'].to_s
      end
      categories
    end
  end
end
