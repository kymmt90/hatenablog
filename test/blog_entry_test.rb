# coding: utf-8

require 'test/unit'

require 'blog_entry'

class BlogEntryTest < Test::Unit::TestCase
  sub_test_case 'load the document from the XML text' do
    setup do
      File.open('test/fixture/entry.xml') do |f|
        @xml = f.read
      end
      @sut = BlogEntry.load_xml(@xml);
    end

    test 'get the entry ID' do
      assert_equal '6653458415122161047', @sut.id
    end

    test 'get the author name' do
      assert_equal 'test_user', @sut.author_name
    end

    test 'get the title' do
      assert_equal 'Test title', @sut.title
    end

    test 'get the URI' do
      assert_equal 'http://test-user.hatenablog.com/entry/2015/01/01/123456', @sut.uri
    end

    test 'get the edit URI' do
      assert_equal 'https://blog.hatena.ne.jp/test_user/test-user.hatenablog.com/atom/entry/6653458415122161047', @sut.edit_uri
    end

    test 'this entry is not draft' do
      assert_false @sut.draft?
    end

    test 'get categores' do
      assert_equal ['Ruby', 'Test'], @sut.categories
    end

    test 'changing categories array does not influence to the original categories array' do
      cats = @sut.categories
      cats << 'Rails'
      cats[1] = 'Sinatra'
      assert_not_equal cats, @sut.categories
    end

    test 'get the content' do
      assert_equal 'This is the test entry.', @sut.content
    end

    test 'get the XML representation' do
      assert_equal @xml, @sut.to_xml
    end

    test 'get each category' do
      actual = []
      @sut.each_category do |category|
        actual << category
      end
      assert_equal ['Ruby', 'Test'], actual
    end
  end

  sub_test_case 'build from initialize arguments' do
    setup do
      @sut = BlogEntry.create(uri: 'http://test-user.hatenablog.com/entry/2015/01/01/123456',
                              edit_uri: 'https://blog.hatena.ne.jp/test_user/test-user.hatenablog.com/atom/entry/6653458415122161047',
                              author_name: 'test_user',
                              title: 'Test title',
                              content: 'This is the test entry.',
                              draft: 'yes',
                              categories: ['Ruby', 'Test'])
    end

    test 'get the entry ID' do
      assert_equal '6653458415122161047', @sut.id
    end

    test 'get the author name' do
      assert_equal 'test_user', @sut.author_name
    end

    test 'get the title' do
      assert_equal 'Test title', @sut.title
    end

    test 'get the URI' do
      assert_equal 'http://test-user.hatenablog.com/entry/2015/01/01/123456', @sut.uri
    end

    test 'get the edit URI' do
      assert_equal 'https://blog.hatena.ne.jp/test_user/test-user.hatenablog.com/atom/entry/6653458415122161047', @sut.edit_uri
    end

    test 'this entry is draft' do
      assert_true @sut.draft?
    end

    test 'get categores' do
      assert_equal ['Ruby', 'Test'], @sut.categories
    end

    test 'get each category' do
      actual = []
      @sut.each_category do |category|
        actual << category
      end
      assert_equal ['Ruby', 'Test'], actual
    end
  end
end
