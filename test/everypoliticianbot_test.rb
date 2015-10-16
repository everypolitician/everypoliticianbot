require 'test_helper'

class EverypoliticianbotTest < Minitest::Test
  class TestDummy
    include Everypoliticianbot::Github
  end

  def test_that_it_has_a_version_number
    refute_nil ::Everypoliticianbot::VERSION
  end

  def test_has_octokit_client
    ENV['GITHUB_ACCESS_TOKEN'] = 'foo'
    subject = TestDummy.new
    assert subject.github.instance_of?(Octokit::Client)
    assert_equal 'foo', subject.github.access_token
  end
end
