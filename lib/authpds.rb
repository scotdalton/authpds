require 'active_support/dependencies'
require 'authlogic'
AUTHPDS_PATH = File.dirname(__FILE__) + "/authpds/"
[ 
  'acts_as_authentic',
  'session',
  'institution',
  'institution_list',
  'exlibris/pds',
  'controllers/authpds_controller',
  'controllers/authpds_user_sessions_controller'
].each do |library|
  require AUTHPDS_PATH + library
end
if ActiveRecord::Base.respond_to?(:add_acts_as_authentic_module)
  ActiveRecord::Base.send(:include, Authpds::ActsAsAuthentic)
end
Authlogic::Session::Base.send(:include, Authpds::Session)
