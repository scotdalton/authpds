module Authpds
  module Session
    module SessionId
      def session_id
        @session_id ||=
          (controller.session.respond_to?(:session_id)) ?
            (controller.session.session_id) ?
              controller.session.session_id : controller.session[:session_id] : controller.session[:session_id]
      end
    end
  end
end