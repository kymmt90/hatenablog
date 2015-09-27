# coding: utf-8

require 'rexml/document'

module Hatena
  class BlogCategory
    def self.load_xml(xml)
      BlogCategory.new(xml)
    end

    def categories
      @categories.dup
    end

    def each
      @categories.each do |category|
        yield category
      end
    end

    def fixed?
      @fixed == 'yes'
    end


    private

      def initialize(xml)
        @document = REXML::Document.new(xml)
        parse_document
      end

      def parse_document
        @categories = []
        @document.each_element("//atom:category") do |category|
          @categories << category.attribute('term').to_s
        end

        @fixed = @document.elements["/app:categories"].attribute('fixed').to_s
        @fixed = 'no' if @fixed.nil?
      end
  end
end
