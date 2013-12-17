module Authpds
  module Helpers
    module Institution
      module ParamHelper
        # The institution param key as configured in UserSession
        def institution_param_key
          @institution_param_key ||= UserSession.institution_param_key
        end

        # The institution param as a Symbol
        def institution_param
          if params["#{institution_param_key}"].present?
            params["#{institution_param_key}"].to_sym
          end
        end
      end
    end
  end
end
