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
        File.open('test/fixture/feed_1.xml') do |f|
          @xml = f.read
        end
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

      test 'changing entries array does not influence to the original entries array' do
        entries = @sut.entries
        entries.pop
        assert_not_equal entries, @sut.entries
      end
    end
  end
end
