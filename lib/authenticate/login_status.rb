module Authenticate

  # Indicate login attempt was successful. Allows caller to supply a block to login() predicated on success?
  class Success
    def success?
      true
    end
  end

  # Indicate login attempt was a failure, with a message.
  # Allows caller to supply a block to login() predicated on success?
  class Failure
    # The reason the sign in failed.
    attr_reader :message

    # @param [String] message The reason the login failed.
    def initialize(message)
      @message = message
    end

    def success?
      false
    end
  end

end

