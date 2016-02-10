require 'rails/generators/base'
require 'generators/authenticate/helpers'

module Authenticate
  module Generators
    class RoutesGenerator < Rails::Generators::Base
      include Authenticate::Generators::Helpers

      source_root File.expand_path('../templates', __FILE__)

      def add_authenticate_routes
        route(authenticate_routes)
      end

      def disable_authenticate_internal_routes
        inject_into_file(
          'config/initializers/authenticate.rb',
          "  config.routes = false \n",
          after: "Authenticate.configure do |config|\n",
        )
      end

      private

      def authenticate_routes
        @user_model = Authenticate.configuration.user_model_route_key
        ERB.new(File.read(routes_file_path)).result(binding)
      end

      def routes_file_path
        File.expand_path(find_in_source_paths('routes.rb'))
      end

    end
  end
end
