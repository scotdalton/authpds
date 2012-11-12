module Authpds
  module Session
    module Authentication
      def authenticated?
        authenticate
      end
      protected :authenticated?

      def authenticate
        # Don't authenticate if the system is inaccessible.
        # If the application session id is nil, skip this check.
        return false if controller.cookies["#{calling_system}_inaccessible".to_sym] == session_id unless session_id.nil?
        # If PDS session already established, authenticate
        return true unless pds_user.nil?
        # Establish a PDS session if the user logged in via an alternative SSO mechanism and this isn't being called after login
        controller.redirect_to sso_url({
          :return_url => controller.request.url }) if valid_sso_session? unless controller.params["action"] =="validate" or controller.performed?
        # Otherwise, do not authenticate
        return false
      end
      protected :authenticate
    end
  end
end