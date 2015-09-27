# coding: utf-8

require 'test/unit'

require './blog_feed'

module Hatena
  class BlogFeedTest < Test::Unit::TestCase
    class << self
      def startup
      end

      def shutdown
      end
    end

    def setup
    end

    def teardown
    end

    sub_test_case 'load the feed from the XML text' do
      setup do
        @xml = <<XML
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom"
      xmlns:app="http://www.w3.org/2007/app">
  <link rel="first" href="https://blog.hatena.ne.jp/test_user}/test-user.hatenablog.com/atom/entry" />
  <link rel="next" href="https://blog.hatena.ne.jp/test_user/test-user.hatenablog.com/atom/entry?page=1377584217" />
  <title>Test Blog</title>
  <link rel="alternate" href="http://test-user.hatenablog.com/"/>
  <updated>2015-01-01T12:34:56+09:00</updated>
  <author>
    <name>test_user</name>
  </author>
  <generator uri="http://blog.hatena.ne.jp/" version="100000000">Hatena::Blog</generator>
  <id>hatenablog://blog/2000000000000</id>

  <entry>
    <id>tag:blog.hatena.ne.jp,2013:blog-test_user-20000000000000-3000000000000000</id>
    <link rel="edit" href="https://blog.hatena.ne.jp/test_user/test-user.hatenablog.com/atom/edit/2500000000"/>
    <link rel="alternate" type="text/html" href="http://test-user.hatenablog.com/entry/2013/09/02/112823"/>
    <author><name>test_user</name></author>
    <title>Test title</title>
    <updated>2015-01-01T12:34:56+09:00</updated>
    <published>2015-01-01T12:34:56+09:00</published>
    <app:edited>2015-01-01T12:34:56+09:00</app:edited>
    <summary type="text">This is the test entry.</summary>
    <content type="text/x-markdown">This is the test entry.</content>
    <hatena:formatted-content xmlns:hatena='http://www.hatena.ne.jp/info/xmlns#' type='text/html'>&lt;p&gt;This is the test entry.&lt;/p&gt;
    </hatena:formatted-content>
    <app:control>
      <app:draft>no</app:draft>
    </app:control>
  </entry>
</feed>
XML

        @sut = BlogFeed.load_xml(@xml)
      end

      test 'get the blog title' do
        assert_equal 'Test Blog', @sut.title
      end

      test 'get the URI' do
        assert_equal 'http://test-user.hatenablog.com/',  @sut.uri
      end

      test 'get the next feed URI' do
        assert_equal 'https://blog.hatena.ne.jp/test_user/test-user.hatenablog.com/atom/entry?page=1377584217',  @sut.next_uri
      end

      test 'get the author name' do
        assert_equal 'test_user', @sut.author_name
      end

      test 'get the last updated datetime' do
        assert_equal '2015-01-01T12:34:56+09:00', @sut.updated.iso8601
      end

      test 'get each entry' do
        @sut.each_entry do |entry|
          assert_equal 'http://test-user.hatenablog.com/entry/2013/09/02/112823', entry.uri
          assert_equal 'https://blog.hatena.ne.jp/test_user/test-user.hatenablog.com/atom/edit/2500000000', entry.edit_uri
          assert_equal '2500000000', entry.id
          assert_equal 'test_user', entry.author_name
          assert_equal 'Test title', entry.title
          assert_equal 'This is the test entry.', entry.content
        end
      end

      test 'the feed has the next feed' do
        assert_true @sut.has_next?
      end
    end
  end
end
