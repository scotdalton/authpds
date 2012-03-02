require 'test_helper'
class ApplicationControllerTest < ActiveSupport::TestCase
  
  def setup
    activate_authlogic
    controller.session[:session_id] = "FakeSessionID"
    InstitutionList.class_variable_set(:@@institutions_yaml_path, nil)
    InstitutionList.instance.instance_variable_set(:@institutions, nil)
    controller.instance_variable_set(:@current_primary_institution, nil)
  end
  
  test "current_user_session_nil" do
    assert_nil(controller.current_user_session)
  end

  test "current_user_session" do
    assert_nil(controller.current_user_session)
    controller.cookies[:PDS_HANDLE] = { :value => VALID_PDS_HANDLE_FOR_NYU }
    user_session = controller.current_user_session
    assert_not_nil(user_session)
  end

  test "current_user_nil" do
    assert_nil(controller.current_user)
  end

  test "current_user" do
    assert_nil(controller.current_user)
    controller.cookies[:PDS_HANDLE] = { :value => VALID_PDS_HANDLE_FOR_NYU }
    user = controller.current_user
    assert_not_nil(user)
    assert_equal("N12162279", user.username)
  end

  test "current_primary_institution_nil" do
    assert_nil(controller.current_primary_institution)
  end

  test "current_primary_institution_default" do
    assert_nil(controller.current_primary_institution)
    controller.request[:session_id] = "FakeSessionID"
    InstitutionList.yaml_path= "#{File.dirname(__FILE__)}/../support/config/institutions.yml"
    assert_equal(InstitutionList.instance.get("NYUAD"), controller.current_primary_institution)
  end


  test "current_primary_institution_user" do
    assert_nil(controller.current_primary_institution)
    InstitutionList.yaml_path= "#{File.dirname(__FILE__)}/../support/config/institutions.yml"
    controller.cookies[:PDS_HANDLE] = { :value => VALID_PDS_HANDLE_FOR_NYU }
    assert_equal("N12162279", controller.current_user.username)
    assert_equal(InstitutionList.instance.get("NYU"), controller.current_user.primary_institution)
    assert_equal(InstitutionList.instance.get("NYU"), controller.current_primary_institution)
  end
end