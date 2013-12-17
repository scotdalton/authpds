module Authpds
  # == Overview
  # The Authpds gem mixes in callbacks to Authlogic for persisting
  # sessions based on a valid PDS handle.
  # The module extends Authlogic and should be compatible with Authlogic configuation.
  # It also provides hooks for custom functionality.
  # The documentation below describes the hooks available, PDS config methods
  # and further details about the module.
  #
  # == Config Options Available
  # :pds_url:: Base pds url
  # :calling_system:: Name of the system (authpds)
  # :anonymous:: Does the system allow anonymous access? (true)
  # :pds_attributes:: Mapping of PDS attributes to record attributes
  # :redirect_logout_url:: Custom redirect logout url
  # :login_inaccessible_url:: Custom url to redirect to in case of PDS system outage
  # :pds_record_identifier:: PDS user method to call to identify record
  # :institution_param_key:: Querystring parameter key for the institution value in this system
  # :validate_url_name:: URL name for validation action in routes (validate_url)
  #
  # == Hooks Available
  # :pds_record_identifier:: Allows for more complex logic in determining what should be used as the record identifier. Defaults to what was set in the pds_record_identifier config.  Returns a Symbol.
  # :attempt_sso:: If there is no PDS handle, can we attempt to establish a PDS session based on some other information?  Returns a Boolean.
  # :additional_authorization:: Allows for additions to the authorization decision.  Returns a Boolean.
  # :additional_attributes:: Allows for additional attributes to be stored in the record.  Returns a Hash.
  # :expiration_date:: Indicates when the record information should be refreshed.  Defaults to one week ago.  Returns a Date or Time.
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
    include Authpds::Session::CoreAttributes
    include Authpds::Session::Authentication
    include Authpds::Session::Authorization
    include Authpds::Session::AuthlogicCallbacks
    include Authpds::Session::Callbacks
    include Authpds::Session::ExceptionHandling
    include Authpds::Session::InstitutionAttributes
    include Authpds::Session::PdsHandle
    include Authpds::Session::PdsUser
    include Authpds::Session::Record
    include Authpds::Session::UrlHandling

    def self.included(klass)
      klass.class_eval do
        extend Authpds::Session::Config
        # Set the Authlogic Cookie Key
        cookie_key "#{calling_system}_credentials"
        # Set the persist_session method
        persist :persist_session
      end
    end
  end
end
