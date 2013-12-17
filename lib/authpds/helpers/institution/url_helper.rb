module Authpds
  module Helpers
    module Institution
      module UrlHelper
        # Include institutional param helper
        include ParamHelper

        # Override Rails #url_for to add institution 
        def url_for(options={})
          if institution_param.present? and options.is_a? Hash
            options[institution_param_key] ||= institution_param
          end
          super options
        end
      end
    end
  end
end
