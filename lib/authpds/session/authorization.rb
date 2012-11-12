module Authpds
  module Session
    module Authorization
      def authorized?
        # Set all the information that is needed to make an authorization decision
        set_record and return authorize
      end
      protected :authorized?

      def authorize
        # If PDS user is not nil (PDS session already established), authorize
        !pds_user.nil? && additional_authorization
      end
    end
  end
end