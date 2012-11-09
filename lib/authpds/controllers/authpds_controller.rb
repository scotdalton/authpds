module Authpds
  module Controllers
    module AuthpdsController

      # Get the current UserSession if it exists
      def current_user_session
        @current_user_session ||= UserSession.find
      end
      helper_method :current_user_session

      # Get the current User if there is a UserSession
      def current_user
        @current_user ||= current_user_session.record unless current_user_session.nil?
      end
      helper_method :current_user, :current_primary_institution

      # Determine current primary institution based on:
      #   0. institutions are not being used (returns nil)
      #   1. institution query string parameter in URL
      #   2. institution associated with the client IP
      #   3. primary institution for the current user
      #   4. first default institution
      def current_primary_institution
        @current_primary_institution ||=
          (institution_param.nil? or all_institutions[institution_param].nil?) ?
            (primary_institution_from_ip.nil?) ?
              (current_user.nil? or current_user.primary_institution.nil?) ?
                Institutions.defaults.first :
                  current_user.primary_institution :
                    primary_institution_from_ip :
                      all_institutions[institution_param]
      end
      helper_method :current_primary_institution

      # Override to add institution.
      def url_for(options={})
        options[institution_param_key] ||= institution_param unless institution_param.nil?
        super options
      end

      def user_session_redirect_url(url)
        (url.nil?) ? (request.referer.nil?) ? root_url : request.referer : url
      end

      # Grab the first institution that matches the client IP
      def primary_institution_from_ip
        Institutions.with_ip(request.remote_ip).first unless request.nil?
      end
      private :primary_institution_from_ip

      def institution_param_key
        @institution_param_key ||= UserSession.institution_param_key
      end
      private :institution_param_key

      def institution_param
        params["#{institution_param_key}"].to_sym unless params["#{institution_param_key}"].nil?
      end
      private :institution_param

      def all_institutions
        Institutions.institutions
      end
      private :all_institutions
    end
  end
end