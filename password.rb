require "bcrypt"
require "base64"
require "minitest/autorun"

# Dropbox implementation based on their article

class Password
  # SecureRandom.bytes(128)
  # Store elsewhere
  KEY = "1803de1949b7ca7a4e8dec8901008a81" 

  attr_reader :input
  def initialize(input)
    @input = input
  end

  def create 
    hashed = Digest::SHA512.hexdigest(input)

    crypted = BCrypt::Password.create(hashed, cost: 10)

    cipher = OpenSSL::Cipher::AES256.new(:CBC)
    cipher.encrypt
    cipher.key = KEY
    encrypted = cipher.update(crypted) + cipher.final

    Base64.encode64(encrypted)
  end

  def match?(stored)
    stored = Base64.decode64(stored)
    cipher = OpenSSL::Cipher::AES256.new(:CBC)
    cipher.decrypt
    cipher.key = KEY
    stored = cipher.update(stored) + cipher.final

    BCrypt::Password.new(stored) == Digest::SHA512.hexdigest(input)
  end

  private
end

class TestPassword < Minitest::Test
  def setup
  end

  def test_match_when_they_are_the_same
    input = "topsecret"
    encrypted = Password.new(input).create
    match = Password.new("topsecret").match?(encrypted)

    assert_equal(match, true)
  end

  def test_match_when_they_are_not_the_same
    input = "topsecret"
    encrypted = Password.new(input).create
    match = Password.new("topsecretzzz").match?(encrypted)

    assert_equal(match, false)
  end
end
