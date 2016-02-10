module Authenticate
  module Generators
    module Helpers
      private

      # Either return the model passed in a classified form or return the default "User".
      def model_class_name
        options[:model] ? options[:model].classify : 'User'
      end

      def model_path
        @model_path ||= File.join('app', 'models', "#{file_path}.rb")
      end

      def file_path
        model_name.underscore
      end

      def namespace
        Rails::Generators.namespace if Rails::Generators.respond_to?(:namespace)
      end

      def namespaced?
        !!namespace
      end

      def model_name
        if namespaced?
          [namespace.to_s] + [model_class_name]
        else
          [model_class_name]
        end.join('::')
      end

      def table_name
        @table_name ||= begin
          base = plural_name
          (class_path + [base]).join('_')
        end
      end

      def class_path
        @class_path
      end

      def singular_name
        @file_name
      end

      def plural_name
        singular_name.pluralize
      end

      def assign_names!(name) #:nodoc:
        @class_path = name.include?('/') ? name.split('/') : name.split('::')
        @class_path.map!(&:underscore)
        @file_name = @class_path.pop
      end

    end
  end
end
