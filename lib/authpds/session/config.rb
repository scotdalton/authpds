module Authpds
  module Session
    module Config
      # Base pds url
      def pds_url(value = nil)
        rw_config(:pds_url, value)
      end
      alias_method :pds_url=, :pds_url

      # Name of the system
      def calling_system(value = nil)
        rw_config(:calling_system, value, "authpds")
      end
      alias_method :calling_system=, :calling_system

      # Does the system allow anonymous access?
      def anonymous(value = nil)
        rw_config(:anonymous, value, true)
      end
      alias_method :anonymous=, :anonymous

      # Mapping of PDS attributes
      def pds_attributes(value = nil)
        value.each_value { |pds_attr|
          pds_attr.gsub!("-", "_") } unless value.nil?
        rw_config(:pds_attributes, value, { email: "email", firstname: "name",
          lastname: "name", primary_institution: "institute" })
      end
      alias_method :pds_attributes=, :pds_attributes

      # Custom redirect logout url
      def redirect_logout_url(value = nil)
        rw_config(:redirect_logout_url, value, "")
      end
      alias_method :redirect_logout_url=, :redirect_logout_url

      # Custom url to redirect to in case of system outage
      def login_inaccessible_url(value = nil)
        rw_config(:login_inaccessible_url, value, "")
      end
      alias_method :login_inaccessible_url=, :login_inaccessible_url

      # PDS user method to call to identify record
      def pds_record_identifier(value = nil)
        rw_config(:pds_record_identifier, value, :id)
      end
      alias_method :pds_record_identifier=, :pds_record_identifier

      # Querystring parameter key for the institution value
      def institution_param_key(value = nil)
        rw_config(:institution_param_key, value, "institute")
      end
      alias_method :institution_param_key=, :institution_param_key

      # URL name for validation action
      def validate_url_name(value = nil)
        rw_config(:validate_url_name, value, "validate_url")
      end
      alias_method :validate_url_name=, :validate_url_name
    end
  end
end