# coding: utf-8

require 'rexml/document'

module Hatena
  class BlogEntry
    attr_reader :uri, :edit_uri, :id, :author_name, :title, :content

    def self.load_xml(xml)
      BlogEntry.new(xml)
    end

    def self.create(uri: '', edit_uri: '', author_name: '', title: '',
                    content: '', draft: 'no', categories: [])

      BlogEntry.new(self.build_xml(uri, edit_uri, author_name, title,
                                   content, draft, categories))
    end

    def draft?
      @draft == 'yes'
    end

    def categories
      @categories.dup
    end

    def each_category
      @categories.each do |category|
        yield category
      end
    end

    def to_xml
      @document.to_s
    end


    private

      def self.build_xml(uri, edit_uri, author_name, title, content, draft, categories)
        xml = <<XML
<?xml version='1.0' encoding='UTF-8'?>
<entry xmlns:app='http://www.w3.org/2007/app' xmlns='http://www.w3.org/2005/Atom'>
<link href='%s' rel='edit'/>
<link href='%s' rel='alternate' type='text/html'/>
<author><name>%s</name></author>
<title>%s</title>
<content type='text/x-markdown'>%s</content>
%s
<app:control>
  <app:draft>%s</app:draft>
</app:control>
</entry>
XML

        categories_tag = categories.inject('') do |s, c|
          s + "<category term=\"#{c}\" />\n"
        end
        xml % [edit_uri, uri, author_name, title, content, categories_tag, draft]
      end

      def initialize(xml)
        @document = REXML::Document.new(xml)
        parse_document
      end

      def parse_document
        @uri = @document.elements["//link[@rel='alternate']"].attribute('href').to_s
        @edit_uri = @document.elements["//link[@rel='edit']"].attribute('href').to_s
        @id = @edit_uri.split('/').last
        @author_name = @document.elements["//author/name"].text
        @title = @document.elements["//title"].text
        @content = @document.elements["//content"].text
        @draft = @document.elements["//app:draft"].text
        @categories = parse_categories
      end

      def parse_categories
        categories = []
        @document.each_element("//category") do |category|
          categories << category.attribute('term').to_s
        end
        categories
      end
  end
end
