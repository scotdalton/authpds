module Authpds
  module Session
    module PdsUser
      def pds_user
        @pds_user ||= Authpds::Exlibris::Pds::BorInfo.new(pds_url,
          calling_system, pds_handle) unless pds_handle.nil?
        return @pds_user unless @pds_user.nil? or @pds_user.error
      rescue Exception => e
        handle_login_exception e
        return nil
      end
    end
  end
end