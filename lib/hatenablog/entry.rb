require 'nokogiri'
require 'time'

module Hatenablog
  module AfterHook
    # Register a hooking method for given methods.
    # The hook method is executed after calling given methods.
    # @param [Symbol] hooking method name
    # @param [Array] hooked methods name array
    def after_hook(hook, *methods)
      methods.each do |method|
        origin_method = "#{method}_origin".to_sym
        if instance_methods.include? origin_method
          raise NameError, "#{origin_method} isn't a unique name"
        end

        alias_method origin_method, method

        define_method(method) do |*args, &block|
          result = send(origin_method, *args, &block)
          send(hook)
        end
      end
    end
  end

  class Entry
    extend AfterHook

    attr_accessor :uri, :author_name, :title, :content, :draft, :categories
    attr_reader :edit_uri, :id, :updated

    def updated=(date)
      @updated = Time.parse(date)
    end

    def edit_uri=(uri)
      @edit_uri = uri
      @id       = uri.split('/').last
    end

    def update_xml
      @document.at_css('author name').content = @author_name
      @document.at_css('title').content = @title
      @document.at_css('link[@rel="alternate"]')['href'] = @uri
      @document.at_css('link[@rel="edit"]')['href'] = @edit_uri
      @document.at_css('content').content = @content
      @document.at_css('entry app|control app|draft').content = @draft
      unless @updated.nil? || @document.at_css('entry updated').nil?
        @document.at_css('entry updated').content = @updated.iso8601
      end
      # unless @categories.nil?
      #   @document.category.remove
      #   @categories.each do |category|
      #     @document.category(term: category)
      #   end
      # end
    end

    after_hook :update_xml, :uri=, :edit_uri=, :author_name=, :title=, :content=, :updated=, :draft=, :categories=

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
      entry = Hatenablog::Entry.new(self.build_xml(uri, edit_uri, author_name, title,
                                                   content, draft, categories, updated))
      yield entry if block_given?
      entry
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
          xml.updated updated unless updated.nil? || updated.empty?
          unless categories.nil?
            categories.each do |category|
              xml.category(term: category)
            end
          end
          xml['app'].control do
            xml['app'].draft draft
          end
        end
      end

      builder.to_xml
    end


    private

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
