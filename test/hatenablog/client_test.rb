require 'test_helper'
require 'test/unit/rr'

require 'hatenablog/client'

module Hatenablog
  class ClientTest < Test::Unit::TestCase
    sub_test_case 'get the single page feed' do
      setup do
        setup_feed
      end

      test 'get the blog title' do
        assert_equal 'Test Blog', @sut.title
      end

      test 'get the blog author name' do
        assert_equal 'test_user', @sut.author_name
      end

      test 'the entries size is 1' do
        assert_equal 1, @sut.entries.count
      end

      test 'get the entry' do
        assert_equal "2500000000", @sut.entries.to_a[0].id
      end

      def setup_feed
        @sut = Hatenablog::Client.create('test/fixture/test_conf.yml')
        requester = Object.new
        response = Object.new
        f = File.open('test/fixture/feed_1.xml')
        stub(response).body { f.read }
        stub(requester).get { response }
        @sut.requester = requester
      end
    end

    sub_test_case 'get the multiple feeds' do
      setup do
        setup_feeds
      end

      test 'the entries size is 2' do
        assert_equal 2, @sut.entries(1).count
      end

      test 'get the first entry' do
        assert_equal "2500000000", @sut.entries(1).to_a[0].id
      end

      test 'get the second entry' do
        assert_equal "2500000001", @sut.entries(1).to_a[1].id
      end

      test 'get entries of the first feed' do
        assert_equal '2500000000', @sut.next_feed.entries.to_a[0].id
      end

      test 'get entries of the next feed' do
        assert_equal '2500000001', @sut.next_feed(@sut_feed1).entries.to_a[0].id
      end

      test 'get no entries when the next feed does not exist' do
        assert_nil @sut.next_feed(@sut_feed2)
      end

      test 'get ArgumentError if pass negative value to Client#entries' do
        assert_raise ArgumentError do
          @sut.entries(-1)
        end
      end

      def setup_feeds
        @sut = Hatenablog::Client.create('test/fixture/test_conf.yml')
        response1  = Object.new
        response2  = Object.new
        requester  = Object.new
        feed1      = File.open('test/fixture/feed_1.xml').read
        feed2      = File.open('test/fixture/feed_2.xml').read
        @sut_feed1 = Feed.load_xml(feed1)
        @sut_feed2 = Feed.load_xml(feed2)

        stub(response1).body { feed1 }
        stub(response2).body { feed2 }
        stub(requester).get(@sut.collection_uri) { response1 }
        stub(requester).get('https://blog.hatena.ne.jp/test_user/test-user.hatenablog.com/atom/entry?page=1377584217') { response2 }
        @sut.requester = requester
      end
    end

    sub_test_case 'get entry' do
      setup do
        setup_entry
        @got_entry = @sut.get_entry('6653458415122161047')
      end

      test 'get the entry ID' do
        assert_equal '6653458415122161047', @got_entry.id
      end

      test 'get the author name' do
        assert_equal 'test_user', @got_entry.author_name
      end

      test 'get the title' do
        assert_equal 'Test title', @got_entry.title
      end

      test 'get the URI' do
        assert_equal 'http://test-user.hatenablog.com/entry/2015/01/01/123456', @got_entry.uri
      end

      test 'get the edit URI' do
        assert_equal 'https://blog.hatena.ne.jp/test_user/test-user.hatenablog.com/atom/edit/6653458415122161047', @got_entry.edit_uri
      end

      test 'this entry is not draft' do
        assert_false @got_entry.draft?
      end

      def setup_entry
        @sut = Hatenablog::Client.create('test/fixture/test_conf.yml')
        requester = Object.new
        response = Object.new
        f = File.open('test/fixture/entry.xml')
        stub(response).body { f.read }
        stub(requester).get { response }
        @sut.requester = requester
      end
    end

    sub_test_case 'post the entry' do
      setup do
        setup_post_entry_mock
      end

      test 'post' do
        @sut.post_entry
      end

      def setup_post_entry_mock
        @sut = Hatenablog::Client.create('test/fixture/test_conf.yml')
        response     = Object.new
        requester = Object.new
        f = File.open('test/fixture/entry.xml')
        mock(response).body { f.read }
        mock(requester).post(@sut.collection_uri, @sut.entry_xml) { response }
        @sut.requester = requester
      end
    end

    sub_test_case 'update the entry' do
      setup do
        setup_update_entry_mock
      end

      test 'update' do
        @sut.update_entry('6653458415122161047')
      end

      def setup_update_entry_mock
        @sut = Hatenablog::Client.create('test/fixture/test_conf.yml')
        response     = Object.new
        requester = Object.new
        f = File.open('test/fixture/entry.xml')
        mock(response).body { f.read }
        mock(requester).put(@sut.member_uri('6653458415122161047'), @sut.entry_xml) { response }
        @sut.requester = requester
      end
    end

    sub_test_case 'delete the entry' do
      setup do
        setup_delete_entry_mock
      end

      test 'delete' do
        @sut.delete_entry('6653458415122161047')
      end

      def setup_delete_entry_mock
        @sut = Hatenablog::Client.create('test/fixture/test_conf.yml')
        requester = Object.new
        mock(requester).delete(@sut.member_uri('6653458415122161047'))
        @sut.requester = requester
      end
    end

    sub_test_case 'get categories' do
      setup do
        setup_categories
        @got_categories = @sut.categories
      end

      test 'get categories' do
        assert_equal ['Perl', 'Scala', 'Ruby'], @got_categories
      end

      def setup_categories
        @sut = Hatenablog::Client.create('test/fixture/test_conf.yml')
        requester = Object.new
        response = Object.new
        f = File.open('test/fixture/categories_1.xml')
        stub(response).body { f.read }
        stub(requester).get { response }
        @sut.requester = requester
      end
    end

    sub_test_case 'helper methods' do
      setup do
        @sut = Hatenablog::Client.create('test/fixture/test_conf.yml')
      end

      test 'collection URI' do
        assert_equal 'https://blog.hatena.ne.jp/test_user/test-user.hatenablog.com/atom/entry', @sut.collection_uri
      end

      test 'member URI' do
        assert_equal 'https://blog.hatena.ne.jp/test_user/test-user.hatenablog.com/atom/entry/6653458415122161047', @sut.member_uri('6653458415122161047')
      end

      test 'category document URI' do
        assert_equal 'https://blog.hatena.ne.jp/test_user/test-user.hatenablog.com/atom/category', @sut.category_doc_uri
      end

      test 'generate entry XML' do
        sut_xml = @sut.entry_xml('test title',
                                 'This is test entry.',
                                 ['Ruby', 'Test'])
        f = File.open('test/fixture/generated_1.xml')
        assert_equal f.read, sut_xml
      end

      test 'generate draft entry XML' do
        sut_xml = @sut.entry_xml('test title',
                                 'This is test entry.',
                                 ['Ruby', 'Test'],
                                 'yes')
        f = File.open('test/fixture/generated_2.xml')
        assert_equal f.read, sut_xml
      end

      test 'generate draft entry XML with the author name' do
        sut_xml = @sut.entry_xml('test title',
                                 'This is test entry.',
                                 ['Ruby', 'Test'],
                                 'yes',
                                 '',
                                 'test_user_2')
        f = File.open('test/fixture/generated_3.xml')
        assert_equal f.read, sut_xml
      end
    end
  end
end
