require 'test_helper'
require 'test/unit/rr'

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
  end
end
