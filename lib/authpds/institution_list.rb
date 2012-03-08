class InstitutionList
  include Singleton # get the instance with InstitutionList.instance
  @@institutions_yaml_path = nil

  def initialize
    @institutions = nil
  end

  # Used for initialization and testing
  def self.yaml_path=(path)
    @@institutions_yaml_path = path
    self.instance.reload
  end
  
  def self.institutions_defined?
    return !@@institutions_yaml_path.nil?
  end

  # Returns an Institution
  def get(name)
    return institutions[name]
  end

  # Returns an array of Institutions
  def defaults
    return institutions.values.find_all {|institution| institution.default === true}
  end

  # Returns an array of Institutions
  def institutions_with_ip(ip)
    return institutions.values.find_all { |institution| institution.includes_ip?(ip) }
  end

  # Reload institutions from the YAML file.
  def reload
    @institutions = nil
    institutions
    true
  end

  # Load institutions from the YAML file and return as a hash.
  def institutions
    unless @institutions
      raise ArgumentError.new("institutions_yaml_path was not specified.") if @@institutions_yaml_path.nil?
      raise NameError.new(
        "The file #{@@institutions_yaml_path} does not exist. "+
        "In order to use the institution feature you must create the file."
      ) unless File.exists?(@@institutions_yaml_path)
      institutions_hash = YAML.load_file( @@institutions_yaml_path )
      institutions_with_parents = {}
      # Prepare institution definitions
      institutions_hash.each do |name, definition|
        definition["name"] = name
        definition["default"] = false unless definition.key?("default")
        institutions_with_parents[name] = definition if definition.key?("parent_institution")
      end
      # Handle inheritance for institutions
      institutions_with_parents.each do |name, definition|
        institutions_hash[name] =  merge_with_parent(institutions_hash, definition)
      end
      # Turn the institution definitions to Institutions
      @institutions = {}
      institutions_hash.each do |name, definition|
        @institutions[name] = Institution.new(definition)
      end
    end
    return @institutions
  end
  
  private 
  def merge_with_parent(institutions, child)
    parent = institutions[child["parent_institution"]]
    return (parent["parent_institution"].nil?) ? parent.merge(child) : merge_with_parent(institutions, parent).merge(child)
  end
end