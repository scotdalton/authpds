module Authpds
  module Controllers
    module AuthpdsSessionsController
      # GET /user_sessions/new
      # GET /login
      def new
        @user_session = UserSession.new(params)
        unless @user_session.login_url.blank?
          redirect_to @user_session.login_url(params)
        else
          raise RuntimeError.new( "Error in #{self.class}.\nNo login url defined")
        end
      end

      # GET /validate
      def validate
        # Only create a new one if it doesn't exist
        @user_session ||= UserSession.create(params[:user_session])
        # If we have a return url, redirect to that otherwise use the root url
        redirect_to (params[:return_url].present?) ? 
          params[:return_url] : root_url
      end

      # DELETE /user_sessions/1
      # GET /logout
      def destroy
        user_session = UserSession.find
        logout_url = user_session.logout_url(params) unless user_session.nil?
        user_session.destroy unless user_session.nil?
        redirect_to user_session_redirect_url(logout_url) unless performed?
      end
    end
  end
end
