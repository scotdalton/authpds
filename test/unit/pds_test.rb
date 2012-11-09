require 'test_helper'

class PdsTest < ActiveSupport::TestCase

  def setup
    @pds_url = "https://logindev.library.nyu.edu"
    @calling_system = "authpds"
    @valid_pds_handle_for_nyu = VALID_PDS_HANDLE_FOR_NYU
    @valid_pds_handle_for_newschool = VALID_PDS_HANDLE_FOR_NEWSCHOOL
    @invalid_pds_handle = INVALID_PDS_HANDLE
    @attribute = "bor_info"
  end

  test "get_attribute_valid" do
    get_attribute = Authpds::Exlibris::Pds::GetAttribute.new(@pds_url, @calling_system, @valid_pds_handle_for_nyu, "bor_info")
    assert_equal("N12162279", get_attribute.response.at("//id").inner_text)
    get_attribute = Authpds::Exlibris::Pds::GetAttribute.new(@pds_url, @calling_system, @valid_pds_handle_for_nyu, "bor_verification")
    assert_equal("N12162279", get_attribute.response.at("//id").inner_text)
    get_attribute = Authpds::Exlibris::Pds::GetAttribute.new(@pds_url, @calling_system, @valid_pds_handle_for_nyu, "bor_id")
    assert_equal("N12162279", get_attribute.response.at("//id").inner_text)
    get_attribute = Authpds::Exlibris::Pds::GetAttribute.new(@pds_url, @calling_system, @valid_pds_handle_for_nyu, "authenticate")
    assert_equal("N12162279", get_attribute.response.at("//id").inner_text)
  end

  test "get_attribute_invalid" do
    get_attribute = Authpds::Exlibris::Pds::GetAttribute.new(@pds_url, @calling_system, @invalid_pds_handle, "bor_info")
    assert_equal("Error User does not exist", get_attribute.error)
  end

  test "bor_info_valid_nyu" do
    nyu = Authpds::Exlibris::Pds::BorInfo.new(@pds_url, @calling_system, @valid_pds_handle_for_nyu)
    assert_equal("N12162279", nyu.id)
    assert_equal("N12162279", nyu.nyuidn)
    assert_equal("51", nyu.bor_status)
    assert_equal("CB", nyu.bor_type)
    assert_equal("SCOT THOMAS", nyu.name)
    assert_equal("SCOT THOMAS", nyu.givenname)
    assert_equal("DALTON", nyu.sn)
    assert_equal("Y", nyu.ill_permission)
    assert_equal("GA", nyu.college_code)
    assert_equal("CSCI", nyu.dept_code)
    assert_equal("Information Systems", nyu.major)
  end

  test "bor_info_valid_newschool" do
    newschool = Authpds::Exlibris::Pds::BorInfo.new(@pds_url, @calling_system, @valid_pds_handle_for_newschool)
    assert_equal("N00206454", newschool.id)
    assert_equal("N00206454", newschool.nyuidn)
    assert_equal("31", newschool.bor_status)
    assert_equal("0", newschool.bor_type)
    assert_equal("true", newschool.newschool_ldap)
    assert_equal("Allen", newschool.name)
    assert_equal("Allen", newschool.givenname)
    assert_equal("Jones", newschool.sn)
    assert_equal("Y", newschool.ill_permission)
  end

  test "bor_info_invalid" do
    get_attribute = Authpds::Exlibris::Pds::BorInfo.new(@pds_url, @calling_system, @invalid_pds_handle)
    assert_equal("Error User does not exist", get_attribute.error)
  end
end
