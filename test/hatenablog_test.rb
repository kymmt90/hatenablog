# coding: utf-8

require 'test/unit'

require './hatenablog'

module Hatena
  class HatenaBlogTest < Test::Unit::TestCase
    class << self
      def startup
        @@sut = HatenaBlog.create('test/fixture/test_conf.yml')
      end

      def shutdown
      end
    end

    def setup
    end

    def teardown
    end

    test 'collection URI' do
      assert_equal 'https://blog.hatena.ne.jp/test_user/example.com/atom/entry', @@sut.send(:collection_uri)
    end

    test 'member URI' do
      assert_equal 'https://blog.hatena.ne.jp/test_user/example.com/atom/entry/123456', @@sut.send(:member_uri, entry_id: '123456')
    end

    test 'category document URI' do
      assert_equal 'https://blog.hatena.ne.jp/test_user/example.com/atom/category', @@sut.send(:category_doc_uri)
    end

    test 'generate entry XML' do
      sut_xml = @@sut.send(:entry_xml,
                           'test title',
                           'This is test entry.',
                           ['Ruby', 'Test'])
      f = File.open('test/fixture/generated_1.xml')
      assert_equal f.read, sut_xml
    end

    test 'generate draft entry XML' do
      sut_xml = @@sut.send(:entry_xml,
                           'test title',
                           'This is test entry.',
                           ['Ruby', 'Test'],
                           'yes')
      f = File.open('test/fixture/generated_2.xml')
      assert_equal f.read, sut_xml
    end

    test 'generate draft entry XML with the author name' do
      sut_xml = @@sut.send(:entry_xml,
                           'test title',
                           'This is test entry.',
                           ['Ruby', 'Test'],
                           'yes',
                           'test_user_2')
      f = File.open('test/fixture/generated_3.xml')
      assert_equal f.read, sut_xml
    end
  end
end
