module Authpds
  module Controllers
    module AuthpdsUserSessionsController

    	# GET /user_sessions/new
    	# GET /login
    	def new
    		@user_session = UserSession.new(params)
    		@user_session.before_login(params) and return if performed?
    		redirect_to @user_session.login_url(params) unless @user_session.login_url.nil?
    		raise RuntimeError.new( "Error in #{self.class}.\nNo login url defined") if @user_session.login_url.nil?
    	end

    	# GET /validate
    	def validate
    		@user_session = UserSession.new(params[:user_session])
    		@user_session.save do |result|
    			@user_session.errors.each {|error|
    				flash[:error] = "There was an error logging in. #{error}"
    				logger.error("Error in #{self.class} while saving user session. #{error}")
    			} unless result
    	    redirect_to (params[:return_url].nil?) ? root_url : params[:return_url]
    		end
    	end

    	# DELETE /user_sessions/1
    	# GET /logout
    	def destroy
    		user_session = UserSession.find
    		logout_url = user_session.logout_url(params)
    		user_session.destroy unless user_session.nil?
    		redirect_to user_session_redirect_url(logout_url)
    	end
    end
  end
end