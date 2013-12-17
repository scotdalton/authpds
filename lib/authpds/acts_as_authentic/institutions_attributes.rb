module Authpds
  module ActsAsAuthentic
    module InstitutionAttributes
      require 'institutions'

      def primary_institution
        unless user_attributes.blank?
          all_institutions[user_attributes[:primary_institution]]
        end
      end

      def primary_institution=(new_primary_institution)
        if new_primary_institution.is_a?(Institutions::Institution)
          new_primary_institution = new_primary_institution.code
        end
        if new_primary_institution.present?
          self.user_attributes = 
            { primary_institution: new_primary_institution.to_sym }
        end
      end

      def institutions
        if user_attributes.present?
          user_attributes[:institutions].collect do |institution| 
            all_institutions[institution]
          end
        end
      end

      def institutions=(new_institutions)
        unless new_institutions.is_a?(Array)
          raise ArgumentError.new("Institutions input should be an array.")
        end
        # Collect the codes as symbols
        new_institutions.collect! do |institution|
          if institution.is_a?(Institutions::Institution)
            institution.code
          else
            insitution.to_sym
          end
        end
        # Whitelist the institutions
        new_institutions = new_institutions.select do |institution|
          all_institutions[institution_code].present?
        end
        # Add them to the user attributes
        if new_institutions.present?
          self.user_attributes = { institutions: new_institutions }
        end
      end

      def all_institutions
        @all_institutions ||= Institutions.institutions
      end
      private :all_institutions
    end
  end
end
