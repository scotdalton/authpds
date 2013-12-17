module Authpds
  module Session
    module Record
      # Get the record associated with this PDS user.
      def get_record(login)
        record = (klass.find_by_smart_case_login_field(login) ||
          klass.new(login_field => login))
      end

      # Set the record information associated with this PDS user.
      def set_record
        self.attempted_record = get_record(pds_user.send(pds_record_identifier))
        self.attempted_record.expiration_date = expiration_date
        # Do this part only if user data has expired.
        reset_record attempted_record if self.attempted_record.expired?
        self.attempted_record.user_attributes= additional_attributes
      end

      # Reset expired data
      def reset_record(attempted_record)
        pds_attributes.each do |record_attr, pds_attr|
          next unless self.attempted_record.respond_to?("#{record_attr}=".to_sym)
          attempted_record.send("#{record_attr}=".to_sym,
            pds_user.send(pds_attr.to_sym))
        end
        pds_user.class.public_instance_methods(false).each do |pds_attr_reader|
          attempted_record.user_attributes = {
            pds_attr_reader.to_sym => pds_user.send(pds_attr_reader.to_sym) }
        end
      end
      private :reset_record
    end
  end
end
