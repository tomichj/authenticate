module Authenticate
  #
  # A secure token, consisting of a big random number.
  #
  class Token
    def self.new
      SecureRandom.hex(20).encode('UTF-8')
    end
  end
end
