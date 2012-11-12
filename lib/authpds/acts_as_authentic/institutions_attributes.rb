module Authpds
  module ActsAsAuthentic
    module InstitutionAttributes
      require 'institutions'

      def primary_institution
        all_institutions[user_attributes[:primary_institution]] unless user_attributes.nil?
      end

      def primary_institution=(new_primary_institution)
        new_primary_institution = new_primary_institution.code if new_primary_institution.is_a?(Institutions::Institution)
        self.user_attributes=({:primary_institution => new_primary_institution.to_sym})
      end

      def institutions
        user_attributes[:institutions].collect { |institution| all_institutions[institution] } unless user_attributes.nil?
      end

      def institutions=(new_institutions)
        raise ArgumentError.new("Institutions input should be an array.") unless new_institutions.is_a?(Array)
        new_institutions.collect! { |institution| institution.to_sym }
        new_institutions.select! { |institution|
          all_institutions[ new_institutions.is_a?(Institutions::Institution) ? institution.code : institution.to_sym]
        }
        self.user_attributes=({:institutions => new_institutions}) unless new_institutions.empty?
      end

      def all_institutions
        @all_institutions ||= Institutions.institutions
      end
      private :all_institutions
    end
  end
end