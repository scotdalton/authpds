module Authpds
  module Controllers
    module AuthpdsController
      module UrlHandling
        # Controller method to generate the Appropriate redirect url
        def user_session_redirect_url(url)
          (url.nil? or url.empty?) ? (request.referer.nil?) ? root_url : request.referer : url
        end
      end
    end
  end
end