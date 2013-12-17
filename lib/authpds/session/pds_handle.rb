module Authpds
  module Session
    module PdsHandle
      def pds_handle
        @pds_handle ||= (controller.cookies[:PDS_HANDLE] ||
          controller.params[:pds_handle])
      end
    end
  end
end
