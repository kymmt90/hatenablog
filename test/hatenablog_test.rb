# coding: utf-8

require 'test/unit'
require 'test/unit/rr'

require 'hatenablog'

class HatenablogTest < Test::Unit::TestCase
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
      assert_equal 1, @sut.entries.length
    end

    test 'get the entry' do
      assert_equal "2500000000", @sut.entries[0].id
    end

    def setup_feed
      @sut = Hatenablog.create('test/fixture/test_conf.yml')
      access_token = Object.new
      response = Object.new
      f = File.open('test/fixture/feed_1.xml')
      stub(response).body { f.read }
      stub(access_token).get { response }
      @sut.access_token = access_token
    end
  end

  sub_test_case 'get the multiple feeds' do
    setup do
      setup_feeds
      @got_entries = @sut.entries(1)
    end

    test 'the entries size is 2' do
      assert_equal 2, @got_entries.length
    end

    test 'get the first entry' do
      assert_equal "2500000000", @got_entries[0].id
    end

    test 'get the second entry' do
      assert_equal "2500000000", @got_entries[1].id
    end

    def setup_feeds
      @sut = Hatenablog.create('test/fixture/test_conf.yml')
      response1    = Object.new
      response2    = Object.new
      access_token = Object.new
      f1 = File.open('test/fixture/feed_1.xml')
      f2 = File.open('test/fixture/feed_2.xml')
      stub(response1).body { f1.read }
      stub(response2).body { f2.read }
      stub(access_token).get(@sut.collection_uri) { response1 }
      stub(access_token).get('https://blog.hatena.ne.jp/test_user/test-user.hatenablog.com/atom/entry?page=1377584217') { response2 }
      @sut.access_token = access_token
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
      @sut = Hatenablog.create('test/fixture/test_conf.yml')
      access_token = Object.new
      response = Object.new
      f = File.open('test/fixture/entry.xml')
      stub(response).body { f.read }
      stub(access_token).get { response }
      @sut.access_token = access_token
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
      @sut = Hatenablog.create('test/fixture/test_conf.yml')
      response     = Object.new
      access_token = Object.new
      f = File.open('test/fixture/entry.xml')
      mock(response).body { f.read }
      mock(access_token).post(@sut.collection_uri, @sut.entry_xml) { response }
      @sut.access_token = access_token
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
      @sut = Hatenablog.create('test/fixture/test_conf.yml')
      response     = Object.new
      access_token = Object.new
      f = File.open('test/fixture/entry.xml')
      mock(response).body { f.read }
      mock(access_token).put(@sut.member_uri('6653458415122161047'), @sut.entry_xml) { response }
      @sut.access_token = access_token
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
      @sut = Hatenablog.create('test/fixture/test_conf.yml')
      access_token = Object.new
      mock(access_token).delete(@sut.member_uri('6653458415122161047'))
      @sut.access_token = access_token
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
      @sut = Hatenablog.create('test/fixture/test_conf.yml')
      access_token = Object.new
      response = Object.new
      f = File.open('test/fixture/categories_1.xml')
      stub(response).body { f.read }
      stub(access_token).get { response }
      @sut.access_token = access_token
    end
  end

  sub_test_case 'OAuth error' do
    setup do
      setup_errors
    end

    test 'fail get' do
      assert_raise(OAuthError.new("Fail to GET: problem")) do
        @sut.get('http://www.example.com')
      end
    end

    test 'fail post' do
      assert_raise(OAuthError.new("Fail to POST: problem")) do
        @sut.post('http://www.example.com')
      end
    end

    test 'fail put' do
      assert_raise(OAuthError.new("Fail to PUT: problem")) do
        @sut.put('http://www.example.com')
      end
    end

    test 'fail delete' do
      assert_raise(OAuthError.new("Fail to DELETE: problem")) do
        @sut.delete('http://www.example.com')
      end
    end

    def setup_errors
      headers = { 'Content-Type' => 'application/atom+xml; type=entry' }

      access_token = Object.new
      stub(access_token).get('http://www.example.com')    { raise 'problem' }
      stub(access_token).post('http://www.example.com',
                             '',
                             headers)                     { raise 'problem' }
      stub(access_token).put('http://www.example.com',
                            '',
                            headers)                      { raise 'problem' }
      stub(access_token).delete('http://www.example.com',
                                headers)                  { raise 'problem' }
      @sut = OAuthAccessToken.new(access_token)
    end
  end

  sub_test_case 'helper methods' do
    setup do
      @sut = Hatenablog.create('test/fixture/test_conf.yml')
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
                               'test_user_2')
      f = File.open('test/fixture/generated_3.xml')
      assert_equal f.read, sut_xml
    end
  end
end
