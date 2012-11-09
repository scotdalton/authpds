require 'test_helper'
class UserSessionsControllerTest < ActiveSupport::TestCase

  def setup
    activate_authlogic
    controller.session[:session_id] = "FakeSessionID"
    controller.cookies[:PDS_HANDLE] = { :value => VALID_PDS_HANDLE_FOR_NYU }
  end

  test "current_user_session" do
    user_session = controller.current_user_session
  end
end