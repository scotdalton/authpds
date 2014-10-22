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
  s.license     = 'MIT'

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "require_all", "~> 1.3.1"
  s.add_dependency "authlogic", "~> 3.4.0"
  s.add_dependency 'activerecord', '>= 3.2.14'
  s.add_dependency 'activesupport', '>= 3.2.14'
  s.add_dependency "nokogiri", "~> 1.6.0"
  s.add_dependency "institutions", "~> 0.1.3"

  s.add_development_dependency "rake", "~> 10.3.0"
  s.add_development_dependency "vcr", "~> 2.9.0"
  s.add_development_dependency "webmock", "~> 1.20.0"
  s.add_development_dependency 'pry', '~> 0.10.1'
end
