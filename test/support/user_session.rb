class UserSession < Authlogic::Session::Base
  pds_url "https://login.library.nyu.edu"
  redirect_logout_url "http://bobcat.library.nyu.edu"
  calling_system "authpds"
  remember_me true
  remember_me_for 300
  httponly true
  secure true
  login_inaccessible_url "http://library.nyu.edu/errors/bobcat-library-nyu-edu/"
  pds_attributes :firstname => "givenname", :lastname => "sn", :email => "email", :primary_institution => "institute" 
  def expiration_date
    1.day.ago
  end
end