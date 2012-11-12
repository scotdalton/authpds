require 'active_support/dependencies'
require 'authlogic'
require 'require_all'
require_all "#{File.dirname(__FILE__)}/authpds/"
# Only include in active record if the model responds to the Authlogic method add_acts_as_authentic_module
ActiveRecord::Base.send(:include, Authpds::ActsAsAuthentic) if ActiveRecord::Base.respond_to?(:add_acts_as_authentic_module)
Authlogic::Session::Base.send(:include, Authpds::Session)
