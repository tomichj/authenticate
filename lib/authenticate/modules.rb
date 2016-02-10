module Authenticate
  module Modules
    extend ActiveSupport::Concern

    # Module to help Authenticate's user model load Authenticate modules.
    #
    # All Authenticate modules implement ActiveSupport::Concern.
    #
    # Modules can optionally define a class method to define what attributes they require present
    # in the user model. For example, :username declares:
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
    module ClassMethods

      # Load all modules declared in Authenticate.configuration.modules.
      # Requires them, then loads as a constant, then checks fields, and finally includes.
      def load_modules
        constants = []
        Authenticate.configuration.modules.each do |mod|
          # puts "load_modules about to load #{mod.to_s}"
          require "authenticate/model/#{mod.to_s}" if mod.is_a?(Symbol)
          mod = load_constant(mod) if mod.is_a?(Symbol)
          constants << mod
        end
        check_fields constants
        constants.each { |mod|
          include mod
        }
      end

      private

      def load_constant module_symbol
        Authenticate::Model.const_get(module_symbol.to_s.classify)
      end

      # For each module, look at the fields it requires. Ensure the User
      # model including the module has the required fields. If it does not
      # have all required fields, huck an exception.
      def check_fields modules
        failed_attributes = []
        instance = self.new
        modules.each do |mod|
          if mod.respond_to?(:required_fields)
            mod.required_fields(self).each do |field|
              failed_attributes << field unless instance.respond_to?(field)
            end
          end
        end

        if failed_attributes.any?
          # fail MissingAttribute.new(failed_attributes)
          Rails.logger.warn "The following attribute(s) is (are) missing on your user model: #{failed_attributes.join(", ")}"
        end
      end

    end

    class MissingAttribute < StandardError
      def initialize(attributes)
        @attributes = attributes
      end

      def message
        "The following attribute(s) is (are) missing on your user model: #{@attributes.join(", ")}"
      end
    end

  end
end

