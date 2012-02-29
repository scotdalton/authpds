module Authpds
  module ActsAsAuthentic
    def self.included(klass)
      klass.class_eval do
        add_acts_as_authentic_module(InstanceMethods, :prepend)
      end
    end

    module InstanceMethods
      def self.included(klass)
        klass.class_eval do
          serialize :user_attributes
          attr_accessor :expiration_date
        end
      end

      public
      # Setting the username field also resets the persistence_token if the value changes.
      def username=(value)
        write_attribute(:username, value)
        reset_persistence_token if username_changed?
      end

      def primary_institution
        return nil unless InstitutionList.institutions_defined?
        InstitutionList.instance.get(user_attributes[:primary_institution]) unless user_attributes.nil?
      end

      def primary_institution=(primary_institution)
        primary_institution = primary_institution.name if primary_institution.is_a?(Institution)
        raise ArgumentError.new(
          "Institution #{primary_institution} does not exist.\n" + 
          "Please maker sure institutions.yml is configured correctly.") if InstitutionList.instance.get(primary_institution).nil?
        self.user_attributes=({:primary_institution => primary_institution})
      end

      def institutions
        return nil unless InstitutionList.institutions_defined?
        user_attributes[:institutions].collect { |institution|
          InstitutionList.instance.get(institution) } unless user_attributes.nil?
      end

      def institutions=(institutions)
        raise ArgumentError.new(
          "Institutions input should be an array.") unless institutions.is_a?(Array)
        filtered_institutions = institutions.collect { |institution|
          institution = institution.name if institution.is_a?(Institution)
          institution unless InstitutionList.instance.get(institution).nil?
        }
        self.user_attributes=({:institutions => filtered_institutions})
      end

      # "Smart" updating of user_attributes.  Maintains user_attributes that are not explicity overwritten.
      def user_attributes=(new_attributes)
        write_attribute(:user_attributes, new_attributes) and return unless new_attributes.kind_of?(Hash)
        # Set new/updated attributes
        write_attribute(:user_attributes, (user_attributes || {}).merge(new_attributes))
      end

      # Defaults to 1.week.ago
      def expiration_date
        @expiration_date ||= 1.week.ago
      end

      # Returns a boolean based on whether the User has been refreshed recently.  
      # If User#refreshed_at is older than User#expiration_date, the User is expired and the data
      # may need to be refreshed.
      def expired?
        # If the record is older than the expiration date, it is expired.
        (refreshed_at.nil?) ? true : refreshed_at < expiration_date 
      end
    end
  end
end