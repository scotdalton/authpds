require 'coveralls'
Coveralls.wear!
require 'rubygems'
require 'authlogic'
require 'authlogic/test_case'
require 'minitest/autorun'
require "test/unit"
require "vcr"
require "active_record"
require "active_record/fixtures"
# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
logger = Logger.new(STDOUT)
logger.level= Logger::FATAL
ActiveRecord::Base.logger = logger
ActiveRecord::Base.configurations = true
ActiveRecord::Schema.define(:version => 1) do
  drop_table :users if table_exists?(:users)
  create_table :users do |t|
    t.string   "username", :default => "", :null => false
    t.string   "email"
    t.string   "firstname", :limit => 100
    t.string   "lastname", :limit => 100
    t.string   "mobile_phone"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "session_id"
    t.string   "persistence_token", :null => false
    t.integer  "login_count", :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.text     "user_attributes"
    t.datetime "refreshed_at"
    t.timestamps
  end unless table_exists?(:users)
end

# Load support files
require File.dirname(__FILE__) + '/../lib/authpds'
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

VCR.configure do |c|
  c.cassette_library_dir = 'test/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
end

class ActiveSupport::TestCase
  VALID_PDS_HANDLE_FOR_NYU = '12112012141859298424685706599355'
  VALID_PDS_HANDLE_FOR_NEWSCHOOL = '12112012151951298522252282669924'
  VALID_PDS_HANDLE_FOR_COOPER = '272201212284614806184193096120278'
  INVALID_PDS_HANDLE = "Invalid"
  SESSION_ID = "qwertyuiopasdfghjkllzxcvbnm1234567890"
  include ActiveRecord::TestFixtures
  include Authlogic::TestCase
  self.fixture_path = File.dirname(__FILE__) + "/fixtures"
  self.use_transactional_fixtures = false
  self.use_instantiated_fixtures  = false
  self.pre_loaded_fixtures = false
  fixtures :users
  setup :activate_authlogic
end

class Authlogic::TestCase::MockController
  def self.helper_method(*args)
  end

  include Authpds::Controllers::AuthpdsController

  def url_for(options={})
    return "http://railsapp.library.nyu.edu/validate?return_url=#{options[:return_url]}"
  end

  def root_url
  end

  def redirect_to(*args)
  end

  def validate_url(options={})
    return "http://railsapp.library.nyu.edu/validate?return_url=#{options[:return_url]}"
  end

  def performed?
    false
  end

  def request
    @request ||= Authlogic::TestCase::MockRequest.new(self)
  end

  def env
    @env ||= {'REMOTE_ADDR' => "128.122.149.239"}
  end
end

class UserSessionsController < Authlogic::TestCase::MockController
  include Authpds::Controllers::AuthpdsSessionsController
end
