require 'test_helper'

class InstitutionTest < ActiveSupport::TestCase

  def setup
  end
  
  test "default" do
    default_name_institution = Institution.new({"name" => "default"})
    assert(default_name_institution.default, "Default name didn't work.")
    regular_institution = Institution.new({"name" => "not_default"})
    assert(!regular_institution.default, "Default attribute didn't work.")
    default_attribute_institution = Institution.new({"name" => "not_default", "default" => "true"})
    assert(default_attribute_institution.default)
  end
  
end