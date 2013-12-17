module Authpds
  module Session
    module ExceptionHandling
      def handle_login_exception(error)
        # Set a cookie saying that we've got some invalid stuff going on
        # in this session.  PDS may be screwy. We want to skip logging in 
        # since it's problematic (if anonymous).
        controller.cookies["#{calling_system}_inaccessible".to_sym] = {
          :value => true, :path => "/" } if anonymous?
        # If anonymous access isn't allowed, we can't rightfully set the cookie.
        # We probably should send to a system down page.
        controller.redirect_to(login_inaccessible_url)
        alert_the_authorities error
      end

      def alert_the_authorities(error)
        controller.logger.error("Error in #{self.class}. " +
          "Something is amiss with PDS authentication.\n" +
            "#{error}\n#{error.backtrace.inspect}")
      end
    end
  end
end
