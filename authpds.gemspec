$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "authpds/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "authpds"
  s.version     = Authpds::VERSION
  s.authors     = ["Scot Dalton"]
  s.email       = ["scotdalton@gmail.com"]
  s.homepage    = "http://github.com/scotdalton/authpds"
  s.summary     = "Allows applications to use Ex Libris' Patron Directory Service (PDS) for authentication."
  s.description = "Libraries that use Ex Libris products, can integrate Rails application with PDS to provide single sign-on across systems."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.0"
  s.add_dependency "authlogic" # used for auth logic :)
  s.add_dependency "nokogiri" # used for xml parsing

  # s.add_development_dependency "sqlite3"
end
