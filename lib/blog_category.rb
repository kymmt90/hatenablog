require 'rexml/document'

class BlogCategory

  # Create a new blog categories from a XML string.
  # @param [String] xml XML string representation
  # @return [BlogCategory]
  def self.load_xml(xml)
    BlogCategory.new(xml)
  end

  # @return [Array]
  def categories
    @categories.dup
  end

  def each
    @categories.each do |category|
      yield category
    end
  end

  # If fixed, only categories in this categories can be used for a blog entry.
  # @return [Boolean]
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
