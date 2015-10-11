require 'test/unit'

require 'hatenablog/category'

module Hatenablog
  class CategoryTest < Test::Unit::TestCase
    sub_test_case 'attribute "fixed" is "yes"' do
      setup do
        File.open('test/fixture/categories_1.xml') do |f|
          @xml = f.read
        end
        @sut = Hatenablog::Category.load_xml(@xml)
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

    sub_test_case 'attribute "fixed" is not exist' do
      setup do
        File.open('test/fixture/categories_2.xml') do |f|
          @xml = f.read
        end
        @sut = Hatenablog::Category.load_xml(@xml)
      end

      test 'the categories list is not fixed' do
        assert_false @sut.fixed?
      end
    end
  end
end
