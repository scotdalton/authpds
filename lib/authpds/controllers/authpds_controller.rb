module Authpds
  module Controllers
    module AuthpdsController
      def self.included(klass)
        klass.class_eval do
          include Authpds::Controllers::AuthpdsController::CoreAttributes
          include Authpds::Controllers::AuthpdsController::InstitutionAttributes
          include Authpds::Controllers::AuthpdsController::UrlHandling
        end
      end
    end
  end
end