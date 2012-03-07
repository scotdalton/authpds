class Institution < Struct.new(:display_name, :name, :default, 
  :application_layout, :ip_addresses, :parent_institution, :view_attributes, :login_attributes)
  require 'ipaddr'

  # Better initializer than Struct gives us, take a hash instead
  # of an ordered array. :services=>[] is an array of service ids,
  # not actual Services!
  def initialize(h={})
    members.each {|m| self.send( ("#{m}=").to_sym , (h.delete("#{m}".to_sym) || h.delete("#{m}"))) }
    # If the institution is named default, take that as an
    # indication that it's the default institution
    default = true if name.eql?("default") or name.eql?("DEFAULT")
    default = false unless default
    # Log the fact that there are left overs in the hash
    # Rails.logger.warn("The following institution settings were ignored: #{h.inspect}.") unless h.empty?
  end

  # Instantiates a new copy of all services included in this institution,
  # returns an array. 
  def instantiate_services!
    services.collect {|s|  }
  end
  
  # Check the list of IP addresses for the given IP
  def includes_ip?(prospective_ip_address)
    return false if ip_addresses.nil?
    ip_prospect = IPAddr.new(prospective_ip_address)
    ip_addresses.each do |ip_address|
      ip_range = (ip_address.match(/[\-\*]/)) ? 
        (ip_address.match(/\-/)) ? 
          (IPAddr.new(ip_address.split("-")[0])..IPAddr.new(ip_address.split("-")[1])) :
            (IPAddr.new(ip_address.gsub(/\*/, "0"))..IPAddr.new(ip_address.gsub(/\*/, "255"))) :
              IPAddr.new(ip_address).to_range
      return true if ip_range === ip_prospect unless ip_range.nil?
    end
    return false;
  end
  
  def to_h
    h = {}
    members.each {|m| h[m.to_sym] = self.send(m)}
    h
  end
end