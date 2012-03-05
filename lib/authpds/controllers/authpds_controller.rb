module Authpds
  module Controllers
    module AuthpdsController

      def self.included(klass)
        klass.class_eval do
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
        #   0. institutions are not being used (returns nil)
        #   1. institution query string parameter in URL
        #   2. institution associated with the client IP
        #   3. primary institution for the current user
        #   4. first default institution
        def current_primary_institution
            @current_primary_institution ||= 
              (InstitutionList.institutions_defined?) ?
                (params["#{institution_param_key}"].nil? or InstitutionList.instance.get(params["#{institution_param_key}"]).nil?) ?
                  (primary_institution_from_ip.nil?) ?
                    (current_user.nil? or current_user.primary_institution.nil?) ?
                      InstitutionList.instance.default_institutions.first :
                        current_user.primary_institution :
                          primary_institution_from_ip :
                            InstitutionList.instance.get(params["#{institution_param_key}"]) :
                              nil
        end

        # Grab the first institution that matches the client IP
        def primary_institution_from_ip
          InstitutionList.instance.institutions_with_ip(request.remote_ip).first unless request.nil?
        end

        # Determine institution layout based on:
        #   1. primary institution's resolve_layout
        #   2. default - views/layouts/application
        def institution_layout
          (current_primary_institution.nil? or current_primary_institution.application_layout.nil?) ? 
            :application : current_primary_institution.application_layout
        end

        # Override to add institution.
        def url_for(options={})
          options["#{institution_param_key}"] = 
            params["#{institution_param_key}"] unless params["#{institution_param_key}"].nil? or 
              options["#{institution_param_key}"]
          super(options)          
        end

        def user_session_redirect_url(url)
          (url.nil?) ? (request.referer.nil?) ? root_url : request.referer : url
        end
        
        def institution_param_key
          @institution_param_key ||= UserSession.insitution_param
        end
      end
    end
  end
end