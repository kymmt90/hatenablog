# coding: utf-8

require 'test/unit'
require 'test/unit/rr'

require 'hatenablog'

class HatenablogTest < Test::Unit::TestCase
  sub_test_case 'get feed' do
    setup do
      setup_feed
    end

    test 'get the blog title' do
      assert_equal 'Test Blog', @sut.title
    end

    test 'get the blog author name' do
      assert_equal 'test_user', @sut.author_name
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

  sub_test_case 'helper methods' do
    setup do
      @sut = Hatenablog.create('test/fixture/test_conf.yml')
    end

    test 'collection URI' do
      assert_equal 'https://blog.hatena.ne.jp/test_user/example.com/atom/entry', @sut.collection_uri
    end

    test 'member URI' do
      assert_equal 'https://blog.hatena.ne.jp/test_user/example.com/atom/entry/6653458415122161047', @sut.member_uri(entry_id: '6653458415122161047')
    end

    test 'category document URI' do
      assert_equal 'https://blog.hatena.ne.jp/test_user/example.com/atom/category', @sut.category_doc_uri
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
