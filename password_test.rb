require_relative "password"
require "minitest/autorun"

class TestPassword < Minitest::Test
  def setup
  end

  def test_match_when_they_are_the_same
    input = "topsecret"
    encrypted, iv = Password.new(input).create
    match = Password.new("topsecret").match?(encrypted, iv)

    assert_equal(match, true)
  end

  def test_match_when_they_are_not_the_same
    input = "topsecret"
    encrypted, iv = Password.new(input).create
    match = Password.new("topsecretzzz").match?(encrypted, iv)

    assert_equal(match, false)
  end
end
