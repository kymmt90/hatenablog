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
      File.open('test/fixture/categories.xml') do |f|
        @xml = f.read
      end
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
