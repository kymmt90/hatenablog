# coding: utf-8

require 'test/unit'

require 'hatenablog'

class HatenablogTest < Test::Unit::TestCase
  class << self
    def startup
      @@sut = Hatenablog.create('test/fixture/test_conf.yml')
    end
  end

  sub_test_case 'helper methods' do
    test 'collection URI' do
      assert_equal 'https://blog.hatena.ne.jp/test_user/example.com/atom/entry', @@sut.collection_uri
    end

    test 'member URI' do
      assert_equal 'https://blog.hatena.ne.jp/test_user/example.com/atom/entry/123456', @@sut.member_uri(entry_id: '123456')
    end

    test 'category document URI' do
      assert_equal 'https://blog.hatena.ne.jp/test_user/example.com/atom/category', @@sut.category_doc_uri
    end

    test 'generate entry XML' do
      sut_xml = @@sut.entry_xml('test title',
                                'This is test entry.',
                                ['Ruby', 'Test'])
      f = File.open('test/fixture/generated_1.xml')
      assert_equal f.read, sut_xml
    end

    test 'generate draft entry XML' do
      sut_xml = @@sut.entry_xml('test title',
                                'This is test entry.',
                                ['Ruby', 'Test'],
                                'yes')
      f = File.open('test/fixture/generated_2.xml')
      assert_equal f.read, sut_xml
    end

    test 'generate draft entry XML with the author name' do
      sut_xml = @@sut.entry_xml('test title',
                                'This is test entry.',
                                ['Ruby', 'Test'],
                                'yes',
                                'test_user_2')
      f = File.open('test/fixture/generated_3.xml')
      assert_equal f.read, sut_xml
    end
  end
end
