require 'rails/generators/base'

#
# deploy view and locale assets
#
module Authenticate
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../../..", __FILE__)

      def create_views
        directory 'app/views'
      end

      def create_locales
        directory 'config/locales'
      end

    end
  end
end
