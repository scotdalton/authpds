module Authpds
  module Controllers
    module AuthpdsController
      include Authpds::Helpers::CurrentUserHelper
      include Authpds::Helpers::Institution::CurrentInstitutionHelper
      include Authpds::Helpers::Institution::UrlHelper

      def self.included(klass)
        # Include 
        klass.class_eval do
          helper_method :current_user_session, :current_user
          helper_method :current_primary_institution
        end
      end

      # Controller method to generate the Appropriate redirect url
      def user_session_redirect_url(url)
        # Work with what we have
        case
        when url.present?
          url
        when request.referer.present?
          request.referer
        else
          root_url
        end
      end
    end
  end
end
