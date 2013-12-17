module Authpds
  module ActsAsAuthentic
    def self.included(klass)
      klass.class_eval do
        add_acts_as_authentic_module(Authpds::ActsAsAuthentic::CoreAttributes, :prepend)
        add_acts_as_authentic_module(Authpds::ActsAsAuthentic::Expiration, :append)
        add_acts_as_authentic_module(Authpds::ActsAsAuthentic::InstitutionAttributes, :append)
      end
    end
  end
end
