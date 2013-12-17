module Authpds
  module Session
    module AuthlogicCallbacks
      # Callback method from Authlogic.
      # Called while trying to persist the session.
      def persist_session
        destroy unless (authenticated? and authorized?) or anonymous?
      end
      protected :persist_session
    end
  end
end
