module Authpds
  module Session
    module InstitutionAttributes
      def institution_attributes
        @institution_attributes ||=
          (controller.current_primary_institution.nil? or controller.current_primary_institution.auth.nil?) ?
            {} : controller.current_primary_institution.auth
      end

      def insitution_code
        @institution_code ||= institution_attributes["code"]
      end
    end
  end
end