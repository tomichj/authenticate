require 'rails/generators/base'

module Authenticate
  module Generators
    class RoutesGenerator < Rails::Generators::Base
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
        File.read(routes_file_path)
      end

      def routes_file_path
        File.expand_path(find_in_source_paths('routes.rb'))
      end

    end
  end
end
