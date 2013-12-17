module Authpds
  module ActsAsAuthentic
    module CoreAttributes
      def self.included(klass)
        klass.class_eval { serialize :user_attributes }
      end

      # Setting the username field also resets the persistence_token if the value changes.
      def username=(value)
        write_attribute(:username, value)
        reset_persistence_token if username_changed?
      end

      # "Smart" updating of user_attributes.
      # Maintains user_attributes that are not explicity overwritten.
      def user_attributes=(new_attributes)
        if new_attributes.kind_of?(Hash)
          # Merge new/updated attributes with new attributes taking precedence
          merged_attributes = (user_attributes || {}).merge(new_attributes)
          write_attribute(:user_attributes, merged_attributes)
        else
          write_attribute(:user_attributes, new_attributes)
        end
      end
    end
  end
end
