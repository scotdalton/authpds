module Authpds
  # == Overview
  # The Authpds gem mixes in callbacks to Authlogic for persisting
  # sessions based on a valid PDS handle.  
  # The module extends Authlogic and should be compatible with Authlogic configuation.
  # It also provides hooks for custom functionality.
  # The documentation below describes the hooks available for overriding, PDS config methods
  # and further details about the module.
  # 
  # == Config Options Available
  # :pds_url:: Base pds url
  # :calling_system:: Name of the system
  # :anonymous:: Does the system allow anonymous access?
  # :pds_attributes:: Mapping of PDS attributes to record attributes
  # :redirect_logout_url:: Custom redirect logout url
  # :login_inaccessible_url:: Custom url to redirect to in case of system outage
  # :pds_record_identifier:: PDS user method to call to identify record
  # :institution_param_key:: Querystring parameter key for the institution value in this system
  # :validate_url_name:: URL name for validation action in routes
  # 
  # == Hooks Available for Overriding
  # :pds_record_identifier:: Allows for more complex logic in determining what should be used as the record identifier. Defaults to what was set in the pds_record_identifier config.
  # :valid_sso_session?:: If there is no PDS handle, can we redirect to PDS to establish a SSO session based on some other information?
  # :additional_authorization:: Allows for additions to the authorization decision
  # :additional_attributes:: Allows for additional attributes to be stored in the record
  # :expiration_date:: Indicates when the record information should be refreshed.  Defaults to one week ago.
  #
  # == Further Implementation Details 
  # === Persisting a Session in AuthLogic
  # When persisting a Session, Authlogic attempts to create the Session based on information available 
  # without having to perform an actual login by calling the :persisting? method. Authologic provides several callbacks from the :persisting?
  # method, e.g. :before_persisting, :persist, :after_persisting.  We're using the :persist callback and setting it to :persist_session.
  # 
  # === Access to the controller in Session
  # The class that Session extends, Authologic::Session::Base, has an explicit handle to the current controller via the instance method 
  # :controller.  This gives our custom instance methods access to cookies, session information, loggers, etc. and also allows them to 
  # perform redirects and renders.
  #
  # === :before_login vs. :login_url
  # :before_login allows for customized processing before the SessionController invokes a redirect or render to a /login page.  It is
  # is fully generic and can be used for any custom purposes.  :login_url is specific for the case of logging in from a remote sytem.  The
  # two methods can be used in conjuction, but any redirects or renders performed in :before_login, will supercede a redirect to :login_url.
  module Session
    def self.included(klass)
      klass.class_eval do
        extend Config
        include AuthpdsCallbackMethods
        include InstanceMethods
        include AuthlogicCallbackMethods
        persist :persist_session
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
        value.each_value { |pds_attr| pds_attr.gsub!("-", "_") } unless value.nil?
        rw_config(:pds_attributes, value, {:email => "email", :firstname => "name", :lastname => "name", :primary_institution => "institute" })
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

      # Querystring parameter key for the institution value
      def institution_param_key(value = nil)
        rw_config(:institution_param_key, value, "institute")
      end
      alias_method :institution_param_key=, :institution_param_key

      # URL name for validation action
      def validate_url_name(value = nil)
        rw_config(:validate_url_name, value, "validate_url")
      end
      alias_method :validate_url_name=, :validate_url_name
    end 
    
    module AuthpdsCallbackMethods
      # Hook for more complicated logic to determine PDS user record identifier
      def pds_record_identifier
        @pds_record_identifier ||= self.class.pds_record_identifier
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
          @pds_user ||= Authpds::Exlibris::Pds::BorInfo.new(self.class.pds_url, self.class.calling_system, pds_handle) unless pds_handle.nil?
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
      def get_record(login)
    		record = klass.find_by_smart_case_login_field(login)
        record = klass.new login_field => login if record.nil?
        return record
      end

      # Set the record information associated with this PDS user.
      def set_record
        self.attempted_record = get_record(pds_user.send(pds_record_identifier))
        self.attempted_record.expiration_date = expiration_date
        # Do this part only if user data has expired.
        if self.attempted_record.expired?
          pds_attributes.each do |record_attr, pds_attr|
            self.attempted_record.send("#{record_attr}=".to_sym, 
              pds_user.send(pds_attr.to_sym)) if self.attempted_record.respond_to?("#{record_attr}=".to_sym)
          end
          pds_user.class.public_instance_methods(false).each do |pds_attr_reader|
            self.attempted_record.user_attributes = {
              pds_attr_reader.to_sym => pds_user.send(pds_attr_reader.to_sym) }
          end
        end
        self.attempted_record.user_attributes= additional_attributes
      end
      
    	# Returns the URL for validating a UserSession on return from a remote login system.
    	def validate_url(params={})
    		url = controller.send(validate_url_name, :return_url => controller.user_session_redirect_url(params[:return_url]))
        return url if params.nil? or params.empty?
        url << "?" if url.match('\?').nil?
        params.each do |key, value|
          next if [:controller, :action, :return_url].include?(key)
          url << "&#{self.class.calling_system}_#{key}=#{value}"
        end
        return url
    	end
    	
      def validate_url_name
        @validate_url_name ||= self.class.validate_url_name
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
    end
  end
end