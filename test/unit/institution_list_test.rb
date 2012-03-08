require 'test_helper'

class InstitutionListTest < ActiveSupport::TestCase

  def setup
    InstitutionList.class_variable_set(:@@institutions_yaml_path, nil)
    InstitutionList.instance.instance_variable_set(:@institutions, nil)
    @yaml_path = "#{File.dirname(__FILE__)}/../support/config/institutions.yml"
    @yaml2_path = "#{File.dirname(__FILE__)}/../support/config/institutions2.yml"
  end
  
  test "yaml_path" do
    assert_raise ArgumentError do
      InstitutionList.yaml_path=  nil
    end
    assert_raise NameError do
      InstitutionList.yaml_path= "garbage_path"
    end
    assert_nothing_raised do
      InstitutionList.yaml_path= @yaml_path
      InstitutionList.instance.institutions
    end
  end
  
  test "defined" do
    assert(!InstitutionList.institutions_defined?)
    InstitutionList.yaml_path= @yaml_path
    assert(InstitutionList.institutions_defined?)
  end
  
  test "defaults" do
    assert_raise ArgumentError do
      InstitutionList.instance.defaults
    end
    assert_nothing_raised do
      InstitutionList.yaml_path= @yaml_path
      InstitutionList.instance.defaults
    end
    assert_not_nil(InstitutionList.instance.defaults)
    assert_equal([InstitutionList.instance.get("NYUAD")], InstitutionList.instance.defaults)
  end
  
  test "institutions_with_ip" do
    assert_raise ArgumentError do
      InstitutionList.instance.institutions_with_ip "128.122.149.122"
    end
    assert_nothing_raised do
      InstitutionList.yaml_path= @yaml_path
      InstitutionList.instance.institutions_with_ip "128.122.149.122"
    end
    assert_not_nil(InstitutionList.instance.institutions_with_ip "128.122.149.122")
    assert_equal([InstitutionList.instance.get("NYU")], InstitutionList.instance.institutions_with_ip("128.122.149.122"))
  end
  
  test "parents" do
    institution_list = YAML.load_file( @yaml2_path )
    # nyu = institution_list["NYU"]
    # puts "Test:#{institution_list}"
    InstitutionList.yaml_path= @yaml2_path
    InstitutionList.instance.institutions
    
  end
end