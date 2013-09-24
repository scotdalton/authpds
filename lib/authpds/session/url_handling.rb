module Authpds
  module Session
    module UrlHandling
      require "cgi"

      # URL to redirect to for login.
      # Preceded by :before_login
      def login_url(params={})
        auth_pds_login_url "load-login", params
      end

      # URL to redirect to in the case of establishing a SSO session.
      def sso_url(params={})
        auth_pds_login_url "sso", params
      end

      # URL to redirect to after logout.
      def logout_url(params={})
        auth_pds_url "logout",
          user_session_redirect_url(redirect_logout_url), params
      end

      def auth_pds_login_url(func, params)
        auth_pds_url func, validate_url(params), 
          :institute => insitution_code, :calling_system => calling_system
      end
      private :auth_pds_login_url

      def auth_pds_url(func, url, params)
        auth_pds_url = "#{pds_url}/pds?func=#{func}"
        params.each_pair do |key, value|
          next if key.blank? or value.blank?
          auth_pds_url << "&#{key}=#{CGI::escape(value)}"
        end
        auth_pds_url << "&url=#{CGI::escape(url)}"
      end
      private :auth_pds_url

      def user_session_redirect_url(url)
        controller.user_session_redirect_url(url)
      end
      private :user_session_redirect_url

      # Returns the URL for validating a UserSession on 
      # return from a remote login system
      def validate_url(params={})
        url = controller.send(validate_url_name, 
          :return_url => user_session_redirect_url(params[:return_url]))
        return url if params.blank?
        url << "?" if url.match('\?').blank?
        params.each do |key, value|
          next if [:controller, :action, :return_url].include?(key)
          next if key.blank? or value.blank?
          url << "&#{calling_system}_#{key}=#{CGI::escape(value)}"
        end
        url
      end
      private :validate_url
    end
  end
end