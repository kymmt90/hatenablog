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
      xml = <<XML
<?xml version='1.0' encoding='UTF-8'?>
<entry xmlns:app='http://www.w3.org/2007/app' xmlns='http://www.w3.org/2005/Atom'>
<link href='%s' rel='edit'/>
<link href='%s' rel='alternate' type='text/html'/>
<author><name>%s</name></author>
<title>%s</title>
<content type='text/x-markdown'>%s</content>
%s%s
<app:control>
  <app:draft>%s</app:draft>
</app:control>
</entry>
XML

      unless updated.nil?
        updated = '<updated>' + updated + '</updated>'
      end
      categories_tag = categories.inject('') do |s, c|
        s + "<category term=\"#{c}\" />\n"
      end
      xml % [edit_uri, uri, author_name, title, content, updated, categories_tag, draft]
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
