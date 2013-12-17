module Authpds
  module Helpers
    module Institution
      module CurrentInstitutionHelper
        # Include institutional param helper
        include ParamHelper

        # Determine current primary institution based on:
        #   0. institutions are not being used (returns nil)
        #   1. institution query string parameter in URL
        #   2. institution associated with the client IP
        #   3. primary institution for the current user
        #   4. first default institution
        def current_primary_institution
          @current_primary_institution ||= case
            when (institution_param.present? && all_institutions[institution_param])
              all_institutions[institution_param]
            when primary_institution_from_ip.present?
              primary_institution_from_ip
            when (@current_user && current_user.primary_institution)
              current_user.primary_institution
            else
              Institutions.defaults.first
            end
        end

        # Grab the first institution that matches the client IP
        def primary_institution_from_ip
          unless request.nil?
            @primary_institution_from_ip ||=
              Institutions.with_ip(request.remote_ip).first
          end
        end
        private :primary_institution_from_ip

        # All institutions
        def all_institutions
          @all_institutions ||= Institutions.institutions
        end
        private :all_institutions
      end
    end
  end
end
