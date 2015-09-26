# coding: utf-8

require 'rexml/document'

module Hatena
  class BlogEntry
    attr_reader :uri, :edit_uri, :id, :author_name, :title, :content

    def self.load_xml(xml)
      BlogEntry.new(xml)
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
