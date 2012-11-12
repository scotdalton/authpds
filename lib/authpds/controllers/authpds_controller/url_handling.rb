module Authpds
  module Controllers
    module AuthpdsController
      module UrlHandling
        # Override Rails ActionController#url_for to add institution.
        def url_for(options={})
          options[institution_param_key] ||= institution_param unless institution_param.nil?
          super options
        end

        # Controller method to generate the Appropriate redirect url
        def user_session_redirect_url(url)
          (url.nil? or url.empty?) ? (request.referer.nil?) ? root_url : request.referer : url
        end
      end
    end
  end
end