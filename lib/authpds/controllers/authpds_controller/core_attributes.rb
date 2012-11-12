module Authpds
  module Controllers
    module AuthpdsController
      module CoreAttributes
        # Set helper methods when this module is included.
        def self.included(klass)
          klass.class_eval do
            helper_method :current_user_session, :current_user
          end
        end

        # Get the current UserSession if it exists
        def current_user_session
          @current_user_session ||= UserSession.find
        end

        # Get the current User if there is a UserSession
        def current_user
          @current_user ||= current_user_session.record unless current_user_session.nil?
        end
      end
    end
  end
end