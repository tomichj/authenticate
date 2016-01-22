module Authenticate

  # Lifecycle stores and runs callbacks for authorization events.
  #
  # Heavily borrowed from warden (https://github.com/hassox/warden).
  #
  # = Events:
  #   :set_user - called after the user object is loaded, either through id/password or via session token.
  #   :authentication - called after the user authenticates with id & password
  #
  # Callbacks are added via after_set_user or after_authentication.
  #
  # Callbacks can throw(:failure,message) to signal an authentication/authorization failure, or perform
  # actions on the user or session.
  #
  # = Options
  #
  # The callback options may optionally specify when to run the callback:
  #   only - executes the callback only if it matches the event(s) given
  #   except - executes the callback except if it matches the event(s) given
  #
  # The callback may also specify a 'name' key in options. This is for debugging purposes only.
  #
  # = Callback block parameters
  #
  # Callbacks are invoked with the following block parameters: |user, session, opts|
  #   user - the user object just loaded
  #   session - the Authenticate::Session
  #   opts - any options you want passed into the callback
  #
  # = Example
  #
  #   # A callback to track the users successful logins:
  #   Authenticate.lifecycle.after_set_user do |user, session, opts|
  #     user.sign_in_count += 1
  #   end
  #
  class Lifecycle
    include Debug
    @@conditions = [:only, :except, :event]

    # This callback is triggered after the first time a user is set during per-hit authorization, or during login.
    def after_set_user(options = {}, method = :push, &block)
      raise BlockNotGiven unless block_given?
      options = process_opts(options)
      # puts "register after_set_user #{options.inspect}"
      after_set_user_callbacks.send(method, [block, options])
    end



    # A callback to run after the user successfully authenticates, during the login process.
    # Mechanically identical to [#after_set_user].
    def after_authentication(options = {}, method = :push, &block)
      raise BlockNotGiven unless block_given?
      options = process_opts(options)
      # puts "register after_authentication #{options}"
      after_authentication_callbacks.send(method, [block, options])
    end


    def run_callbacks(kind, *args) # args - |user, session, opts|
      # Last callback arg MUST be a Hash
      options = args.last
      d "@@@@@@@@@@@@ run_callbacks kind:#{kind} options:#{options.inspect}"

      # each callback has 'conditions' stored with it
      send("#{kind}_callbacks").each do |callback, conditions|
        conditions = conditions.dup # make a copy, we mutate it
        d "running callback -- #{conditions.inspect}"
        conditions.delete_if {|key, val| !@@conditions.include? key}
        # d "conditions after filter:#{conditions.inspect}"
        invalid = conditions.find do |key, value|
          # d "!!!!!!! conditions key:#{key} value:#{value}      options[key]:#{options[key].inspect}"
          # d("!value.include?(options[key]):#{!value.include?(options[key])}") if value.is_a?(Array)
          value.is_a?(Array) ? !value.include?(options[key]) : (value != options[key])
        end
        d "callback invalid? #{invalid.inspect}"
        callback.call(*args) unless invalid
      end
      d "FINISHED run_callbacks #{kind}"
      nil
    end


    def prepend_after_authentication(options = {}, &block)
      after_authentication(options, :unshift, &block)
    end

    private

    # set event: to run callback on based on options
    def process_opts(options)
      if options.key?(:only)
        options[:event] = options.delete(:only)
      elsif options.key?(:except)
        options[:event] = [:set_user, :authentication] - Array(options.delete(:except))
      end
      options
    end


    def after_set_user_callbacks
      @after_set_user_callbacks ||= []
    end

    def after_authentication_callbacks
      @after_authentication_callbacks ||= []
    end
  end


  def self.lifecycle
    @lifecycle ||= Lifecycle.new
  end

  def self.lifecycle=(lifecycle)
    @lifecycle = lifecycle
  end
end