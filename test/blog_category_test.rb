# coding: utf-8

require 'test/unit'

require './blog_category'

module Hatena
  class BlogCategoryTest < Test::Unit::TestCase
    class << self
      def startup
      end

      def shutdown
      end
    end

    def setup
      @xml = <<XML
<?xml version="1.0" encoding="utf-8"?>
<app:categories
    xmlns:app="http://www.w3.org/2007/app"
    xmlns:atom="http://www.w3.org/2005/Atom"
    fixed="yes">
  <atom:category term="Perl" />
  <atom:category term="Scala" />
  <atom:category term="Ruby" />
</app:categories>
XML
      @sut = BlogCategory.load_xml(@xml)
    end

    def teardown
    end

    test 'get the categories list' do
      assert_equal ['Perl', 'Scala', 'Ruby'], @sut.categories
    end

    test 'changing the categories array does not influence to the original categories array' do
        categories = @sut.categories
        categories << 'Rails'
        categories[1] = 'Sinatra'
        assert_not_equal categories, @sut.categories
    end

    test 'get each category' do
      categories = []
      @sut.each do |category|
        categories << category
      end
      assert_equal ['Perl', 'Scala', 'Ruby'], categories
    end

    test 'the categories list is fixed' do
      assert_true @sut.fixed?
    end
  end
end
