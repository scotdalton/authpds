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
    return institutions.values.find_all {|institution| institution.default == true}
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
      institution_list = YAML.load_file( @@institutions_yaml_path )
      @institutions = {}
      # Turn the institution hashes to Institutions
      institution_list.each_pair do |institution_name, institution_hash|
        institution_hash["name"] = institution_name
        # Merge with parent institution
        institution_hash = 
          institution_list[institution_hash["parent_institution"]].
            merge(institution_hash) unless institution_hash["parent_institution"].nil?
        @institutions[institution_name] = Institution.new(institution_hash)
      end
    end
    return @institutions
  end
end