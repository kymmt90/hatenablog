# coding: utf-8

require './blog_entry'
require 'rexml/document'
require 'time'

module Hatena
  class BlogFeed
    attr_reader :uri, :next_uri, :title, :author_name, :updated

    def self.load_xml(xml)
      BlogFeed.new(xml)
    end

    def each_entry
      @entries.each do |entry|
        yield entry
      end
    end


    private

      def initialize(xml)
        @document = REXML::Document.new(xml)
        parse_document
      end

      def parse_document
        @uri = @document.elements["/feed/link[@rel='alternate']"].attribute('href').to_s
        @next_uri = @document.elements["/feed/link[@rel='next']"].attribute('href').to_s
        @title = @document.elements["/feed/title"].text
        @author_name = @document.elements["//author/name"].text
        @updated = Time.parse(@document.elements["/feed/updated"].text)
        parse_entry
      end

      def parse_entry
        @entries = []
        @document.elements.collect("//entry") do |entry|
          # add namespace 'app' to recognize XML correctly
          entry.add_attribute('xmlns:app', 'http://www.w3.org/2007/app')
          @entries << BlogEntry.load_xml(entry.to_s)
        end
      end
  end
end
