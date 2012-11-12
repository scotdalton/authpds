module Authpds
  module ActsAsAuthentic
    module Expiration
      def self.included(klass)
        klass.class_eval do
          attr_accessor :expiration_date
        end
      end

      # Returns a boolean based on whether the User has been refreshed recently.
      # If User#refreshed_at is older than User#expiration_date, the User is expired and the data
      # may need to be refreshed.
      def expired?
        # If the record is older than the expiration date, it is expired.
        (refreshed_at.nil?) ? true : refreshed_at < expiration_date
      end
    end
  end
end