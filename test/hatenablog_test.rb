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
      xml = <<XML
<?xml version="1.0" encoding="utf-8"?>
<entry xmlns="http://www.w3.org/2005/Atom"
       xmlns:app="http://www.w3.org/2007/app">
  <title>test title</title>
  <author><name>test_user</name></author>
  <content type="text/x-markdown">This is test entry.</content>
  <category term="Ruby" />
<category term="Test" />

  <app:control>
    <app:draft>no</app:draft>
  </app:control>
</entry>
XML
      assert_equal xml, sut_xml
    end

    test 'generate draft entry XML' do
      sut_xml = @@sut.send(:entry_xml,
                           'test title',
                           'This is test entry.',
                           ['Ruby', 'Test'],
                           'yes')
      xml = <<XML
<?xml version="1.0" encoding="utf-8"?>
<entry xmlns="http://www.w3.org/2005/Atom"
       xmlns:app="http://www.w3.org/2007/app">
  <title>test title</title>
  <author><name>test_user</name></author>
  <content type="text/x-markdown">This is test entry.</content>
  <category term="Ruby" />
<category term="Test" />

  <app:control>
    <app:draft>yes</app:draft>
  </app:control>
</entry>
XML
      assert_equal xml, sut_xml
    end

    test 'generate draft entry XML with the author name' do
      sut_xml = @@sut.send(:entry_xml,
                           'test title',
                           'This is test entry.',
                           ['Ruby', 'Test'],
                           'yes',
                           'test_user_2')
      xml = <<XML
<?xml version="1.0" encoding="utf-8"?>
<entry xmlns="http://www.w3.org/2005/Atom"
       xmlns:app="http://www.w3.org/2007/app">
  <title>test title</title>
  <author><name>test_user_2</name></author>
  <content type="text/x-markdown">This is test entry.</content>
  <category term="Ruby" />
<category term="Test" />

  <app:control>
    <app:draft>yes</app:draft>
  </app:control>
</entry>
XML
      assert_equal xml, sut_xml
    end
  end
end
