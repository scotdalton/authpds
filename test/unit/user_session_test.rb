require 'test_helper'
class UserSessionTest < ActiveSupport::TestCase
  
  def setup
    activate_authlogic
    controller.session[:session_id] = "FakeSessionID"
    controller.cookies[:PDS_HANDLE] = { :value => VALID_PDS_HANDLE_FOR_NYU }
  end
  
  test "login_url" do
    user_session = UserSession.new
    assert_equal(
      "https://logindev.library.nyu.edu/pds?func=load-login&institute=&calling_system=authpds&url=http%3A%2F%2Frailsapp.library.nyu.edu%2Fvalidate%3Freturn_url%3D", 
        user_session.send(:login_url))
  end
  
  test "logout_url" do
    user_session = UserSession.new
    assert_equal(
      "https://logindev.library.nyu.edu/pds?func=logout&url=https%253A%252F%252Flogindev.library.nyu.edu%252Flogout", 
        user_session.send(:logout_url))
  end
  
  test "validate_url" do
    user_session = UserSession.new
    assert_equal(
      "http://railsapp.library.nyu.edu/validate?return_url=http://railsapp.library.nyu.edu", 
        user_session.validate_url(:return_url => "http://railsapp.library.nyu.edu"))
    assert_equal(
      "http://railsapp.library.nyu.edu/validate?return_url=http://railsapp.library.nyu.edu&authpds_custom_param1=custom_param1", 
        user_session.validate_url(:controller => "test_controller", 
          :action => "test_action", :return_url => "http://railsapp.library.nyu.edu",
            :custom_param1 => "custom_param1"))
  end
  
  test "pds_handle" do
    user_session = UserSession.new
    assert_equal(VALID_PDS_HANDLE_FOR_NYU, user_session.send(:pds_handle))
  end
  
  test "pds_user" do
    user_session = UserSession.new
    pds_user = user_session.pds_user
    assert_instance_of(Authpds::Exlibris::Pds::BorInfo, pds_user)
    assert_equal("N12162279", pds_user.username)
    assert_equal("N12162279", pds_user.id)
    assert_equal("std5", pds_user.uid)
    assert_equal("N12162279", pds_user.nyuidn)
    assert_equal("51", pds_user.bor_status)
    assert_equal("CB", pds_user.bor_type)
    assert_equal("true", pds_user.opensso)
    assert_equal("Scot Thomas", pds_user.name)
    assert_equal("Scot Thomas", pds_user.firstname)
    assert_equal("Dalton", pds_user.lastname)
    assert_equal("Y", pds_user.ill_permission)
    assert_equal("GA", pds_user.college_code)
    assert_equal("CSCI", pds_user.dept_code)
    assert_equal("Information Systems", pds_user.major)
  end
  
  test "persist_session" do
    user_session = UserSession.new
    assert_nil(controller.session["authpds_credentials"])
    assert_nil(user_session.send(:attempted_record))
    assert_nil(user_session.record)
    assert_no_difference('User.count') do
      user_session.send(:persist_session)
    end
    assert_not_nil(user_session.send(:attempted_record))
    assert_nil(user_session.record)
    assert_equal("N12162279", user_session.send(:attempted_record).username)
  end
  
  test "after_login" do
    user_session = UserSession.new
    assert_nil(controller.session["auth_test_credentials"])
    assert_nil(user_session.send(:attempted_record))
    assert_nil(user_session.record)
    assert_no_difference('User.count') {
        user_session.send(:after_login)
    }
    assert_nil(controller.session["auth_test_credentials"])
    assert_not_nil(user_session.send(:attempted_record))
    assert_nil(user_session.record)
    assert_equal("N12162279", user_session.send(:attempted_record).username)
  end
  
  test "find" do
    user_session = UserSession.new
    assert_nil(controller.session["authpds_credentials"])
    assert_nil(user_session.send(:attempted_record))
    assert_nil(user_session.record)
    assert_difference('User.count') {
        user_session = UserSession.find
    }
    assert_not_nil(controller.session["authpds_credentials"])
    assert_not_nil(user_session.send(:attempted_record))
    assert_not_nil(user_session.record)
    assert_equal(controller.session["authpds_credentials"], user_session.record.persistence_token)
    assert_equal("N12162279", user_session.record.username)
  end
end