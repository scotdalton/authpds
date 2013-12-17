[![Gem Version](https://badge.fury.io/rb/authpds.png)](http://badge.fury.io/rb/authpds)
[![Build Status](https://api.travis-ci.org/scotdalton/authpds.png?branch=master)](https://travis-ci.org/scotdalton/authpds)
[![Dependency Status](https://gemnasium.com/scotdalton/authpds.png)](http://gemnasium.com/scotdalton/authpds)
[![Code Climate](https://codeclimate.com/github/scotdalton/authpds.png)](http://codeclimate.com/github/scotdalton/authpds)
[![Coverage Status](https://coveralls.io/repos/scotdalton/authpds/badge.png?branch=master)](https://coveralls.io/r/scotdalton/authpds)

# Authpds
Libraries for authenticating via Ex Libris' Patron Directory Services (PDS) and provides
hooks for making authorization decisions based on the user information provided by PDS.
It leverages the [authlogic](https://github.com/binarylogic/authlogic) gem and depends
on a User-like model.

## Basics
### Generate User-like model
    $ rails generate model User username:string email:string firstname:string \
      lastname:string mobile_phone:string crypted_password:string password_salt:string \
      session_id:string persistence_token:string login_count:integer last_request_at:string \
      current_login_at:string last_login_at:string last_login_ip:string current_login_ip:string \
      user_attributes:text refreshed_at:datetime

### Configure User-like model
    class User < ActiveRecord::Base
      serialize :user_attributes  

      acts_as_authentic do |c|
        c.validations_scope = :username
        c.validate_password_field = false
        c.require_password_confirmation = false  
        c.disable_perishable_token_maintenance = true
      end
    end

### Generate UserSession model
    $ rails generate authlogic:session user_session

### Configure UserSession with Authpds options
    class UserSession < Authlogic::Session::Base
      pds_url "https://login.library.institution.edu"
      redirect_logout_url "http://library.institution.edu"
      calling_system "my_system"

      def expiration_date
        1.second.ago
      end
    end

### Create UserSessions controller
    $ rails generate controller UserSessions --no-assets --no-helper

### Configure institutions

#### Create institutions.yml file
Calling the institution "default" will make it the default:

    default:
      login:
        code: INST01
      display_name: My Institution

An alternative syntax:

    INST01:
      login:
        code: INST01
      default: true
      display_name: My Institution

You can create multiple institution listings as follows:

    INST01:
      login:
        code: INST01
      default: true
      display_name: My Institution
    INST02:
      login:
        code: INST01
      display_name: Your Institution

The two separate institutions above share a code in this example.
The code attribute determines the institute parameter in the PDS url.

#### Institution fields
| `name` | Institution name |
| `display_name` | Name to display to users. |
| `default` | Boolean indicating whether this is a default Institution.
Alternatively, an Institution can be named 'default'.|
| `parent_institution` | A parent Institution from which this child will inherit fields. |
| `ip_addresses` | IP addresses associated with the Institution. |
| `login` | Login configurations associated with the Institution. |
| `layouts` | Layout configurations associated with the Institution. |
| `views` | View configurations associated with the Institution. |
| `controllers` | Controller configurations associated with the Institution. |
| `models` | Model configurations associated with the Institution. |
  

#### Create institution initializer

Most likely it will just work if you put the config file in 

    "#{Rails.root}/config/institutions.yml"

If you have your institutions config file in another location make sure to
change the line below accordingly.

    Institutions.loadpaths << File.join("other", "path")
    Institutions.filenames << "other_file.yml"

### Mixin authpds methods into UserSessionsController
    class UserSessionsController < ApplicationController
      require 'authpds'
      include Authpds::Controllers::AuthpdsSessionsController
    end

### Mixin authpds methods into ApplicationController
    class ApplicationController < ActionController::Base
      protect_from_forgery
      require 'authpds'
      include Authpds::Controllers::AuthpdsController
    end

### Mixin institutions url helpers into ApplicationHelper
    module ApplicationHelper
      include Authpds::Helpers::Institution::UrlHelper
    end

## Overview
The Authpds gem mixes in callbacks to Authlogic for persisting sessions based on a valid PDS handle.
The module extends Authlogic and should be compatible with Authlogic configuation.
It also provides hooks for custom functionality.
The documentation below describes the hooks available for overriding, PDS config methods
and further details about the module.

## Config Accessors Available
| `#pds_url` | Base pds url |
| `#calling_system` | Name of the system (authpds) |
| `#anonymous` | Does the system allow anonymous access? (true) |
| `#pds_attributes` | Mapping of PDS attributes to record attributes |
| `#redirect_logout_url` | Custom redirect logout url |
| `#login_inaccessible_url` | Custom url to redirect to in case of PDS system outage |
| `#pds_record_identifier` | PDS user method to call to identify record |
| `#institution_param_key` | Querystring parameter key for the institution value in this system |
| `#validate_url_name` | URL name for validation action in routes (validate_url) |

## Hooks Available for Overriding
| `#pds_record_identifier` | Allows for more complex logic in determining what should be
used as the record identifier. Defaults to what was set in the `pds_record_identifier` config.
Returns a Symbol. |
| `#attempt_sso?` | If there is no PDS handle, can we attempt to establish a PDS
session based on some other information?  Returns a Boolean. |
| `#additional_authorization` | Allows for additions to the authorization decision. Returns a Boolean. |
| `#additional_attributes` | Allows for additional attributes to be stored in the record. Returns a Hash. |
| `#expiration_date` | Indicates when the record information should be refreshed.
Defaults to one week ago.  Returns a Date or Time. |

## Further Implementation Details 
### Persisting a Session in AuthLogic
When persisting a Session, Authlogic attempts to create the Session based on information available 
without having to perform an actual login by calling the `#persisting?` method. 
Authologic provides several callbacks from the `#persisting?`
method, e.g. `#before_persisting`, `#persist`, `#after_persisting`.
We're using the `#persist` callback and setting it to `#persist_session`.

### Access to the controller in Session
The class that Session extends, Authologic::Session::Base, has an explicit handle to the current
controller via the instance method `#controller`. This gives our custom instance methods access to
cookies, session information, loggers, etc. and also allows them to perform redirects and renders.
