module Authpds
  module Controllers
    module AuthpdsController
      module InstitutionAttributes
        require 'institutions'

        # Set helper methods when this module is included.
        def self.included(klass)
          klass.class_eval do
            helper_method :current_primary_institution
          end
        end

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
          @all_institutions ||= Institutions.institutions
        end
        private :all_institutions
      end
    end
  end
end