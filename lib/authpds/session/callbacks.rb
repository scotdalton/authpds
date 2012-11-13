module Authpds
  module Session
    module Callbacks
      # Hook for more complicated logic to determine PDS user record identifier
      def pds_record_identifier
        @pds_record_identifier ||= pds_record_identifier
      end

      # Hook to determine if we should set up an SSO session
      def valid_sso_session?
        return false
      end

      # Hook to provide additional authorization requirements
      def additional_authorization
        return true
      end

      # Hook to add additional user attributes.
      def additional_attributes
        {}
      end

      # Hook to update expiration date if necessary
      def expiration_date
        1.week.ago
      end
    end
  end
end