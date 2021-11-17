require 'test_helper'
require 'test/unit/rr'

require 'hatenablog/requester'

module Hatenablog
  class RequesterTest < Test::Unit::TestCase
    sub_test_case 'OAuth error' do
      setup do
        setup_errors
      end

      test 'fail get' do
        assert_raise(Hatenablog::Requester::RequestError.new("Fail to GET: problem")) do
          @sut.get('http://www.example.com')
        end
      end

      test 'fail post' do
        assert_raise(Hatenablog::Requester::RequestError.new("Fail to POST: problem")) do
          @sut.post('http://www.example.com')
        end
      end

      test 'fail put' do
        assert_raise(Hatenablog::Requester::RequestError.new("Fail to PUT: problem")) do
          @sut.put('http://www.example.com')
        end
      end

      test 'fail delete' do
        assert_raise(Hatenablog::Requester::RequestError.new("Fail to DELETE: problem")) do
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
        @sut = Hatenablog::Requester::OAuth.new(access_token)
      end
    end

    sub_test_case 'Basic' do
      URL = 'http://www.example.com'

      test 'get' do
        setup_basic_auth
        req = @sut.get(URL)
        assert_equal 'GET', req.method
        assert_equal 'Basic dGVzdF91c2VyOnN1a3c5ZTg3Zmc=', req['authorization']
      end

      test 'post' do
        setup_basic_auth
        req = @sut.post(URL, 'body', {'Foo' => 'bar'})
        assert_equal 'POST', req.method
        assert_equal 'Basic dGVzdF91c2VyOnN1a3c5ZTg3Zmc=', req['authorization']
        assert_equal 'body', req.body
        assert_equal 'bar', req['Foo']
      end

      test 'put' do
        setup_basic_auth
        req = @sut.put(URL, 'body', {'Foo' => 'bar'})
        assert_equal 'PUT', req.method
        assert_equal 'Basic dGVzdF91c2VyOnN1a3c5ZTg3Zmc=', req['authorization']
        assert_equal 'body', req.body
        assert_equal 'bar', req['Foo']
      end

      test 'delete' do
        setup_basic_auth
        req = @sut.delete(URL, {'Foo' => 'bar'})
        assert_equal 'DELETE', req.method
        assert_equal 'Basic dGVzdF91c2VyOnN1a3c5ZTg3Zmc=', req['authorization']
        assert_equal 'bar', req['Foo']
      end

      test 'raise error' do
        setup_basic_auth(error: true)
        assert_raise(Hatenablog::Requester::RequestError.new("Fail to GET: problem")) do
          @sut.get('http://www.example.com')
        end
      end

      def setup_basic_auth(error: false)
        user_id = 'test_user'
        api_key = 'sukw9e87fg'
        @sut = Hatenablog::Requester::Basic.new(user_id, api_key)

        any_instance_of(Net::HTTP) do |http|
          if error
            stub(http).request { raise 'problem' }
          else
            stub(http).request { |req| req }
          end
        end
      end
    end
  end
end
