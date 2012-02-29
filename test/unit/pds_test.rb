require 'test_helper'

class PdsTest < ActiveSupport::TestCase
  
  def setup
    @pds_url = "https://login.library.nyu.edu"
    @calling_system = "authpds"
    @valid_pds_handle_for_nyu = VALID_PDS_HANDLE_FOR_NYU
    @valid_pds_handle_for_newschool = VALID_PDS_HANDLE_FOR_NEWSCHOOL
    @invalid_pds_handle = INVALID_PDS_HANDLE
    @attribute = "bor_info"
    # Ordered in Ruby 1.9 so :uid will overwrite id
    @bor_info_attributes = { :id => "id", :uid => "uid", 
      :opensso => "opensso", :name => "name", :firstname => "givenname", 
      :lastname => "sn", :commonname => "cn", :email => "email",
      :nyuidn => "nyuidn", :verification => "verification", :institute => "institute",
      :bor_status => "bor-status", :bor_type => "bor-type",
      :college_code => "college_code", :college_name => "college_name",
      :dept_name => "dept_name", :dept_code => "dept_code",
      :major_code => "major_code", :major => "major", :ill_permission => "ill-permission", 
      :newschool_ldap => "newschool_ldap" }
  end
  
  test "get_attribute_valid" do
    get_attribute = Authpds::Exlibris::Pds::GetAttribute.new(@pds_url, @calling_system, @valid_pds_handle_for_nyu, "bor_info")
    assert_equal("N12162279", get_attribute.response.at("//id").inner_text)
    get_attribute = Authpds::Exlibris::Pds::GetAttribute.new(@pds_url, @calling_system, @valid_pds_handle_for_nyu, "bor_verification")
    assert_equal("N12162279", get_attribute.response.at("//id").inner_text)
    get_attribute = Authpds::Exlibris::Pds::GetAttribute.new(@pds_url, @calling_system, @valid_pds_handle_for_nyu, "authenticate")
    assert_equal("N12162279", get_attribute.response.at("//id").inner_text)
    get_attribute = Authpds::Exlibris::Pds::GetAttribute.new(@pds_url, @calling_system, @valid_pds_handle_for_nyu, "bor_id")
    assert_equal("N12162279", get_attribute.response.at("//id").inner_text)
  end
  
  test "get_attribute_invalid" do
    get_attribute = Authpds::Exlibris::Pds::GetAttribute.new(@pds_url, @calling_system, @invalid_pds_handle, "bor_info")
    assert_equal("Error User does not exist", get_attribute.error)
  end
  
  test "bor_info_valid" do
    nyu = Authpds::Exlibris::Pds::BorInfo.new(@pds_url, @calling_system, @valid_pds_handle_for_nyu, @bor_info_attributes)
    assert_equal("N12162279", nyu.id)
    assert_equal("std5", nyu.uid)
    assert_equal("N12162279", nyu.nyuidn)
    assert_equal("51", nyu.bor_status)
    assert_equal("CB", nyu.bor_type)
    assert_equal("true", nyu.opensso)
    assert_equal("Scot Thomas", nyu.name)
    assert_equal("Scot Thomas", nyu.firstname)
    assert_equal("Dalton", nyu.lastname)
    assert_equal("Y", nyu.ill_permission)
    assert_equal("GA", nyu.college_code)
    assert_equal("CSCI", nyu.dept_code)
    assert_equal("Information Systems", nyu.major)
    newschool = Authpds::Exlibris::Pds::BorInfo.new(@pds_url, @calling_system, @valid_pds_handle_for_newschool, @bor_info_attributes)
    assert_equal("N00206454", newschool.id)
    assert_equal("314519567249252", newschool.uid)
    assert_equal("N00206454", newschool.nyuidn)
    assert_equal("31", newschool.bor_status)
    assert_equal("0", newschool.bor_type)
    assert_equal("true", newschool.newschool_ldap)
    assert_equal("Allen", newschool.name)
    assert_equal("Allen", newschool.firstname)
    assert_equal("Jones", newschool.lastname)
    assert_equal("Y", newschool.ill_permission)
  end
  
  test "bor_info_invalid" do
    get_attribute = Authpds::Exlibris::Pds::BorInfo.new(@pds_url, @calling_system, @invalid_pds_handle, @bor_info_attributes)
    assert_equal("Error User does not exist", get_attribute.error)
  end
end
