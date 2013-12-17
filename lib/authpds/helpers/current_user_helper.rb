module Authpds
  module Helpers
    module CurrentUserHelper
      # Get the current UserSession if it exists
      def current_user_session
        @current_user_session ||= UserSession.find
      end

      # Get the current User if there is a UserSession
      def current_user
        if current_user_session.present? 
          @current_user ||= current_user_session.record
        end
      end
    end
  end
end
