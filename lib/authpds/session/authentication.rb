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
        return false if controller.cookies["#{calling_system}_inaccessible".to_sym] == true
        # If PDS session already established, authenticate
        return true unless pds_user.nil?
        # Try to establish a PDS session if the user logged in via an alternative 
        # SSO mechanism and this isn't being called after login
        unless controller.params["action"] =="validate" or controller.performed?
          controller.redirect_to sso_url({ :return_url => controller.request.url }) if attempt_sso?
        end
        # Definitely, do not authenticate if we got this far
        return false
      end
      protected :authenticate
    end
  end
end
