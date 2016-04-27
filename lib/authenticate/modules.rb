module Authenticate
  #
  # Modules injects Authenticate modules into the app User model.
  #
  # Any module being loaded into User can optionally define a class method `required_fields(klass)` defining
  # any required attributes in the User model. For example, the :username module declares:
  #
  #   module Username
  #     extend ActiveSupport::Concern
  #
  #     def self.required_fields(klass)
  #       [:username]
  #     end
  #     ...
  #
  # If the model class is missing a required field, Authenticate will fail with a MissingAttribute error.
  # The error will declare what required fields are missing.
  module Modules
    extend ActiveSupport::Concern
    #
    # Class methods injected into User model.
    #
    module ClassMethods
      #
      # Load all modules declared in Authenticate.configuration.modules.
      # Requires them, then loads as a constant, then checks fields, and finally includes.
      #
      # @raise MissingAttribute if attributes required by Authenticate are missing.
      def load_modules
        modules_to_include = []
        Authenticate.configuration.modules.each do |mod|
          # The built-in modules are referred to by symbol. Additional module classes (constants) can be added
          # via Authenticate.configuration.modules.
          require "authenticate/model/#{mod}" if mod.is_a?(Symbol)
          mod = load_constant(mod) if mod.is_a?(Symbol)
          modules_to_include << mod
        end
        check_fields modules_to_include
        modules_to_include.each { |mod| include mod }
      end

      private

      def load_constant(module_symbol)
        Authenticate::Model.const_get(module_symbol.to_s.classify)
      end

      # For each module, look at the fields it requires. Ensure the User
      # model including the module has the required fields.
      # @raise MissingAttribute if required attributes are missing.
      def check_fields(modules)
        failed_attributes = []
        instance = new
        modules.each do |mod|
          if mod.respond_to?(:required_fields)
            mod.required_fields(self).each { |field| failed_attributes << field unless instance.respond_to?(field) }
          end
        end

        if failed_attributes.any?
          raise MissingAttribute.new(failed_attributes),
                "Required attribute are missing on your user model: #{failed_attributes.join(', ')}"
        end
      end
    end

    # Thrown if required attributes are missing.
    class MissingAttribute < StandardError
      def initialize(attributes)
        @attributes = attributes
      end

      def message
        "Required attributes are missing on your user model: #{@attributes.join(', ')}"
      end
    end
  end
end
