module Authpds
  module Session
    module PdsUser
      def pds_user
        begin
          @pds_user ||= Authpds::Exlibris::Pds::BorInfo.new(pds_url, calling_system, pds_handle) unless pds_handle.nil?
          return @pds_user unless @pds_user.nil? or @pds_user.error
        rescue Exception => e
          # Delete the PDS_HANDLE, since this isn't working.
          # controller.cookies.delete(:PDS_HANDLE) unless pds_handle.nil?
          handle_login_exception e
          return nil
        end
      end
    end
  end
end