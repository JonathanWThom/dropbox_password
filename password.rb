require "bcrypt"
require "base64"

class Password
  # SecureRandom.bytes(128)
  # Store elsewhere. This is just an example.
  PEPPER = "1803de1949b7ca7a4e8dec8901008a81" 

  attr_reader :input
  def initialize(input)
    @input = input
  end

  def create 
    hashed = Digest::SHA512.hexdigest(input)

    crypted = BCrypt::Password.create(hashed, cost: 10)

    cipher = OpenSSL::Cipher::AES256.new(:CBC)
    cipher.encrypt
    cipher.key = PEPPER 
    iv = cipher.random_iv
    encrypted = cipher.update(crypted) + cipher.final

    [Base64.encode64(encrypted), Base64.encode64(iv)]
  end

  def match?(stored, iv)
    decoded = Base64.decode64(stored)
    decoded_iv = Base64.decode64(iv)

    decipher = OpenSSL::Cipher::AES256.new(:CBC)
    decipher.decrypt
    decipher.key = PEPPER 
    decipher.iv = decoded_iv
    decrypted = decipher.update(decoded) + decipher.final

    BCrypt::Password.new(decrypted) == Digest::SHA512.hexdigest(input)
  end
end
