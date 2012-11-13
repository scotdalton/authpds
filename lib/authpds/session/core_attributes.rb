module Authpds
  module Session
    module CoreAttributes
      def anonymous
        @anonymous ||=self.class.anonymous
      end
      alias anonymous? anonymous

      def calling_system
        @calling_system ||= self.class.calling_system
      end
      
      def login_inaccessible_url
        @login_inaccessible_url ||= self.class.login_inaccessible_url
      end

      def pds_attributes
        @pds_attributes ||= self.class.pds_attributes
      end

      def pds_record_identifier
        @pds_record_identifier ||= self.class.pds_record_identifier
      end

      def pds_url
        @pds_url ||= self.class.pds_url
      end

      def redirect_logout_url
        @redirect_logout_url ||= self.class.redirect_logout_url
      end

      def validate_url_name
        @validate_url_name ||= self.class.validate_url_name
      end
    end
  end
end