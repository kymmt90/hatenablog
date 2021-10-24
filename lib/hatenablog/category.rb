require 'nokogiri'

module Hatenablog
  class Category

    # Create a new blog categories from a XML string.
    # @param [String] xml XML string representation
    # @return [Hatenablog::Category]
    def self.load_xml(xml)
      Hatenablog::Category.new(xml)
    end

    # @return [Array]
    def categories
      @categories.dup
    end

    def each(&block)
      return enum_for unless block_given?

      @categories.each do |category|
        block.call(category)
      end
    end

    # If fixed, only categories in this categories can be used for a blog entry.
    # @return [Boolean]
    def fixed?
      @fixed == 'yes'
    end


    private

    def initialize(xml)
      @document = Nokogiri::XML(xml)
      parse_document
    end

    def parse_document
      @categories = @document.css('atom|category').inject([]) do |categories, category|
        categories << category['term'].to_s
      end

      @fixed = @document.at_css('app|categories')['fixed'].to_s
      @fixed = 'no' if @fixed.nil?
    end
  end
end
