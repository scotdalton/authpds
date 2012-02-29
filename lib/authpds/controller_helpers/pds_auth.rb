module Authpds
  module ControllerHelpers
    module Authpds

      def self.included(klass)
        klass.class_eval do
          include AuthpdsConfigurable
          AuthpdsConfigurable.set_default_configuration!(klass.authpds_config)
          include InstanceMethods
          helper_method :current_user_session, :current_user, :current_primary_institution
        end
      end
    
      module InstanceMethods

        # Get the current UserSession if it exists
        def current_user_session
          @current_user_session ||= UserSession.find
        end

        # Get the current User if there is a UserSession
        def current_user
          @current_user ||= current_user_session.record unless current_user_session.nil?
        end

        # Determine current primary institution based on:
        #   1. institution query string parameter in URL
        #   2. institution associated with the client IP
        #   3. primary institution for the current user
        #   4. "default_institution" defined in AppConfig
        #   5. first default institution
        def current_primary_institution
            @current_primary_institution ||= 
              (params["institution"].nil? or InstitutionList.instance.get(params["institution"]).nil?) ?
                (primary_institution_from_ip.nil?) ?
                  (current_user.nil? or current_user.primary_institution.nil?) ?
                    (AppConfig.param("default_institution").nil?) ?
                      InstitutionList.instance.default_institutions.first :
                        InstitutionList.instance.get(AppConfig.param("default_institution")) : 
                          current_user.primary_institution :
                            primary_institution_from_ip :
                              InstitutionList.instance.get(params["institution"])
        end

        # Grab the first institution that matches the client IP
        def primary_institution_from_ip
          InstitutionList.instance.institutions_with_ip(request.remote_ip).first unless request.nil?
        end

        # Determine institution layout based on:
        #   1. primary institution's resolve_layout
        #   2. default - views/layouts/application
        def institution_layout
          (current_primary_institution.nil? or current_primary_institution.resolve_layout.nil?) ? 
            :application : current_primary_institution.resolve_layout
        end

        # Override to add institution.
        def url_for(options={})
          options["institution"] = params["institution"] unless params["institution"].nil? or options["institution"]
          super(options)          
        end

        def user_session_redirect_url(url)
          (url.nil?) ? (request.referer.nil?) ? root_url : request.referer : url
        end
      end
    end
  end
end