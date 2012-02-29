class UserSession < Authlogic::Session::Base
  pds_url "https://logindev.library.nyu.edu"
  redirect_logout_url "https://logindev.library.nyu.edu/logout"
  calling_system "authpds"
  remember_me true
  remember_me_for 300
  httponly true
  secure true
  pds_attributes :username => "id", :id => "id", :uid => "uid", 
    :opensso => "opensso", :name => "name", :firstname => "givenname", 
    :lastname => "sn", :commonname => "cn", :email => "email",
    :nyuidn => "nyuidn", :verification => "verification", :institute => "institute",
    :bor_status => "bor-status", :bor_type => "bor-type",
    :college_code => "college_code", :college_name => "college_name",
    :dept_name => "dept_name", :dept_code => "dept_code",
    :major_code => "major_code", :major => "major", :ill_permission => "ill-permission", 
    :newschool_ldap => "newschool_ldap"
end