module Authpds
  # == Overview
  # The Auth module mixes in callbacks to Authlogic::Session::Base for persisting, 
  # validating and managing the destruction of sessions.  The module also provides
  # instance methods used by the SessionController for managing UserSessions before 
  # login and redirecting to login and logout urls.
  # The methods in this module are intended to be overridden for custom authentication/authorization
  # needs.  The documentation below describes the methods available for overriding, convenience methods
  # available for use by custom implementations, instructions for mixing in custom implementations and
  # further details about the module.
  # 
  # == Methods Available for Overriding
  # :on_every_request:: Used for creating a UserSession without the User having to explicitly login, thereby supporting single sign-on. 
  #                     When overridden, implementations should update the UserSession User, via UserSession#get_user based
  #                     on custom authentication/authorization criteria.  Authlogic will take care of the rest by saving the User
  #                     and creating the UserSession.
  # :before_login:: Allows for custom logic immediately before a login is initiated.  If a controller :redirect_to or :render 
  #                 is performed, the directive will supercede :login_url. Precedes :login_url.
  # :login_url::  Should return a custom login URL for redirection to when logging in via a remote system.
  #               If undefined, /login will go to the UserSession login view,
  #               default user_session/new).  Preceded by :before_login.
  # :after_login::  Used for creating a UserSession after login credentials are provided.  When overridden, 
  #                 custom implementations should update the UserSession User, via UserSession#get_user based 
  #                 on authentication/authorization criteria.  Authlogic will take care of the rest
  #                 by saving the User and creating the UserSession.
  # :before_logout:: Allows for custom logic immediately before logout is performed
  # :after_logout:: Allows for custom logic immediately after logout is performed
  # :redirect_logout_url:: Should return a custom logout URL for redirection to after logout has been performed.  
  #               Allows for single sign-out via a remote system.
  #
  # == Convenience Methods for Use by Custom Implementations
  # UserSession#controller::  Returns the current controller.  Used for accessing cookies and session information,
  #                           performing redirects, etc.
  # UserSession#get_user::  Returns the User for updating by :on_every_request and :after_login.  Returns an existing User
  #                         if she exists, otherwise creates a new User.
  # UserSession#validate_url:: Returns the URL for validating a UserSession on return from a remote login system.
  # User#expiration_period=:: Sets the expiration date for the User. Default is one week ago.
  # User#refreshed_at=:: Sets the last time the User was refreshed and saves the value to the database.
  # User#expired?:: Returns a boolean based on whether the User has been refreshed recently.  
  #                 If User#refreshed_at is older than User#expiration_date, the User is expired and the data
  #                 may need to be refreshed.
  # User#user_attributes=:: "Smart" updating of user_attributes.  Maintains user_attributes that are not explicity overwritten.
  # 
  # == Mixing in Custom Implementations
  # Once you've built your class, you can mix it in to Authlogic with the following config setting in config/environment.rb
  #       config.app_config.login = { 
  #         :module => :PDS,
  #         :cookie_name => "user_credentials_is_the_default"
  #         :remember_me => true|false
  #         :remember_me_for => seconds, e.g. 5.minutes }
  #
  # == Further Implementation Details 
  # === Persisting a UserSession in AuthLogic
  # When persisting a UserSession, Authlogic attempts to create the UserSession based on information available 
  # without having to perform an actual login by calling the :persisting? method. Authologic provides several callbacks from the :persisting?
  # method, e.g. :before_persisting, :persist, :after_persisting.  We're using the :persist callback and setting it to :on_every_request.
  # 
  # === Validating a UserSession in AuthLogic
  # When validating a UserSession, Authlogic attempts to create the UserSession based on information available 
  # from login by calling the :valid? method. Authologic provides several callbacks from the :valid?
  # method, e.g. :before_validation, :validate, :after_validation.  We're using the :validate callback and setting it to :after_login.
  #
  # === Access to the controller in UserSession
  # The class that UserSession extends, Authologic::Session::Base, has an explicit handle to the current controller via the instance method 
  # :controller.  This gives our custom instance methods the access to cookies, session information, loggers, etc. and also allows them to 
  # perform redirects and renders.
  #
  # === :before_login vs. :login_url
  # :before_login allows for customized processing before the UserSessionController invokes a redirect or render to a /login page.  It is
  # is fully generic and can be used for any custom purposes.  :login_url is specific for the case of logging in from a remote sytem.  The
  # two methods can be used in conjuction, but any redirects or renders performed in :before_login, will supercede a redirect to :login_url.
  #
  # === UserSession#get_user vs. UserSession#attempted_record
  # Both UserSession#get_user and UserSession#attempted_record provide access to the instance variable @attempted_record, but 
  # UserSession#get_user set the instance variable to either an existing User (based on the username parameter), or creates a new User
  # for use by implementing systems.  If custom implementations want to interact directly with UserSession#attempted_record and 
  # @attempted_record, they are welcome to do so.
  module Session
    def self.included(klass)
      klass.class_eval do
        extend Config
        include AuthpdsCallbackMethods
        include InstanceMethods
        include AuthlogicCallbackMethods
        persist :persist_session
        validate :after_login
        before_destroy :before_logout
        after_destroy :after_logout
      end
    end
    
    module Config
      # Base pds url
      def pds_url(value = nil)
        rw_config(:pds_url, value)
      end
      alias_method :pds_url=, :pds_url

      # Name of the system
      def calling_system(value = nil)
        rw_config(:calling_system, value, "authpds")
      end
      alias_method :calling_system=, :calling_system

      # Does the system allow anonymous access?
      def anonymous(value = nil)
        rw_config(:anonymous, value, true)
      end
      alias_method :anonymous=, :anonymous

      # Mapping of PDS attributes
      def pds_attributes(value = nil)
        rw_config(:pds_attributes, value, {:id => "id", :email => "email", :firstname => "name", :lastname => "name" })
      end
      alias_method :pds_attributes=, :pds_attributes

      # Custom redirect logout url
      def redirect_logout_url(value = nil)
        rw_config(:redirect_logout_url, value, "")
      end
      alias_method :redirect_logout_url=, :redirect_logout_url

      # Custom url to redirect to in case of system outage
      def login_inaccessible_url(value = nil)
        rw_config(:login_inaccessible_url, value, "")
      end
      alias_method :redirect_logout_url=, :redirect_logout_url

      # PDS user method to call to identify record
      def pds_record_identifier(value = nil)
        rw_config(:pds_record_identifier, value, :id)
      end
      alias_method :pds_record_identifier=, :pds_record_identifier

      # PDS user method to call to get users primary institution
      def pds_record_primary_institution(value = nil)
        rw_config(:pds_record_primary_institution, value, :institute)
      end
      alias_method :pds_record_primary_institution=, :pds_record_primary_institution

      # Querystring parameter key for the institution value
      def institution_param_key(value = nil)
        rw_config(:institution_param_key, value, "institute")
      end
      alias_method :institution_param_key=, :institution_param_key
    end 
    
    module AuthpdsCallbackMethods
      # Hook for more complicated logic to determine PDS user record identifier
      def pds_record_identifier
        self.class.pds_record_identifier
      end

      # Hook for more complicated logic to determine PDS user primary institution
      def pds_record_primary_institution
        self.class.pds_record_primary_institution
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
    
    module InstanceMethods
      require "cgi"

      def self.included(klass)
        klass.class_eval do
          cookie_key "#{calling_system}_credentials"
        end
      end

      # Called by the user session controller login is initiated.
      # Precedes :login_url
      def before_login(params={})
      end

      # URL to redirect to for login.
      # Preceded by :before_login
      def login_url(params={})
        return "#{self.class.pds_url}/pds?func=load-login&institute=#{institution_attributes["link_code"]}&calling_system=#{self.class.calling_system}&url=#{CGI::escape(validate_url(params))}"
      end

      # URL to redirect to after logout.
      def logout_url(params={})
        return "#{self.class.pds_url}/pds?func=logout&url=#{CGI::escape(CGI::escape(self.class.redirect_logout_url))}"
      end
      
      # URL to redirect to in the case of establishing a SSO session.
      def sso_url(params={})
        return "#{self.class.pds_url}/pds?func=sso&institute=#{institution_attributes["link_code"]}&calling_system=#{self.class.calling_system}&url=#{CGI::escape(validate_url(params))}"
      end

      def pds_user
        begin
          @pds_user ||= Authpds::Exlibris::Pds::BorInfo.new(self.class.pds_url, self.class.calling_system, pds_handle, pds_attributes) unless pds_handle.nil?
          return @pds_user unless @pds_user.nil? or @pds_user.error
        rescue Exception => e
          # Delete the PDS_HANDLE, since this isn't working.
          # controller.cookies.delete(:PDS_HANDLE) unless pds_handle.nil?
          handle_login_exception e
          return nil
        end
      end
      
      private
      def authenticated?
        authenticate
      end

      def authenticate
        return false if controller.cookies["#{self.class.calling_system}_inaccessible".to_sym] == session_id
        # If PDS session already established, authenticate
        return true unless pds_user.nil?
        # Establish a PDS session if the user logged in via an alternative SSO mechanism and this isn't being called after login
        controller.redirect_to sso_url({
          :return_url => controller.request.url }) if valid_sso_session? unless controller.params["action"] =="validate" or controller.performed?
        # Otherwise, do not authenticate
        return false
      end

      def authorized?
        # Set all the information that is needed to make an authorization decision
        set_record and return authorize
      end

      def authorize
        # If PDS user is not nil (PDS session already established), authorize
        !pds_user.nil? && additional_authorization
      end
      
      # Get the record associated with this PDS user.
      def get_record(username)
    		record = klass.send(:find_by_username, username)
        record = klass.new :username => username if record.nil?
        return record
      end

      # Set the record information associated with this PDS user.
      def set_record
        self.attempted_record = get_record(pds_user.send(pds_record_identifier))
        self.attempted_record.expiration_date = expiration_date
        # Do this part only if user data has expired.
        if self.attempted_record.expired?
          self.attempted_record.primary_institution= pds_user.send(pds_record_primary_institution)
          pds_attributes.each_key { |user_attr|
            self.attempted_record.send("#{user_attr}=".to_sym, 
              pds_user.send(user_attr.to_sym)) if self.attempted_record.respond_to?("#{user_attr}=".to_sym)
            self.attempted_record.user_attributes = {
              user_attr.to_sym => pds_user.send(user_attr.to_sym) }}
        end
        self.attempted_record.user_attributes= additional_attributes
      end
      
    	# Returns the URL for validating a UserSession on return from a remote login system.
    	def validate_url(params={})
    		url = controller.validate_url(:return_url => controller.user_session_redirect_url(params[:return_url]))
        return url if params.nil? or params.empty?
        url << "?" if url.match('\?').nil?
        params.each do |key, value|
          next if [:controller, :action, :return_url].include?(key)
          url << "&#{self.class.calling_system}_#{key}=#{value}"
        end
        return url
    	end

      def institution_attributes
        @institution_attributes = 
          (controller.current_primary_institution.nil? or controller.current_primary_institution.login_attributes.nil?) ?
            {} : controller.current_primary_institution.login_attributes
      end
      
      def pds_attributes
        @pds_attributes ||= self.class.pds_attributes
      end

      def session_id
        @session_id ||=
          (controller.session.respond_to?(:session_id)) ?
            (controller.session.session_id) ?
              controller.session.session_id : controller.session[:session_id] : controller.session[:session_id]
      end

      def anonymous?
        self.class.anonymous
      end

      def pds_handle
        return controller.cookies[:PDS_HANDLE] || controller.params[:pds_handle]
      end

      def handle_login_exception(error)
        # Set a cookie saying that we've got some invalid stuff going on
        # in this session.  Either PDS is screwy, OpenSSO is screwy, or both.
        # Either way, we want to skip logging in since it's problematic (if anonymous).
        controller.cookies["#{self.class.calling_system}_inaccessible".to_sym] = {
          :value => session_id,
          :path => "/" } if anonymous?
        # If anonymous access isn't allowed, we can't rightfully set the cookie.
        # We probably should send to a system down page.
        controller.redirect_to(self.class.login_inaccessible_url)
        alert_the_authorities error
      end

      def alert_the_authorities(error)
        controller.logger.error("Error in #{self.class}. Something is amiss with PDS authentication.\n#{error}\n#{error.backtrace.inspect}}")
      end
    end

    module AuthlogicCallbackMethods
      private
      # Callback method from Authlogic.
      # Called while trying to persist the session.
      def persist_session
        destroy unless (authenticated? and authorized?) or anonymous?
      end
      
      # Callback method from Authlogic.
      # Called while validating on session save.
      def after_login
        authenticated? and authorized?
      end

      # Callback method from Authlogic.
      # Called before destroying UserSession.
      def before_logout
      end

      # Callback method from Authlogic.
      # Called after destroying UserSession.
      def after_logout
      end
    end
  end
end