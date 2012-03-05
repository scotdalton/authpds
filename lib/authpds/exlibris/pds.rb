module Authpds
  module Exlibris
    module Pds
      require 'nokogiri'
      require 'uri'
      require 'net/http'

      # Makes a call to the PDS get-attribute API.
      # Defaults attribute equal to "bor_info".
      # Raises an exception on if it encounters errors.
      class GetAttribute
        attr_reader :response, :error

        protected
        # Call to the PDS API.
        def initialize(pds_url, calling_system, pds_handle, attribute)
          raise ArgumentError.new("Argument Error in #{self.class}. :pds_url not specified in config.") if pds_url.nil?;
          raise ArgumentError.new("Argument Error in #{self.class}. :calling_system not specified in config.") if calling_system.nil?;
          raise ArgumentError.new("Argument Error in #{self.class}. :pds_handle is null.") if pds_handle.nil?;
          raise ArgumentError.new("Argument Error in #{self.class}. :attribute is null.") if pds_handle.nil?;
          pds_uri = URI.parse("#{pds_url}/pds?func=get-attribute&attribute=#{attribute}&calling_system=#{calling_system}&pds_handle=#{pds_handle}")
          http = Net::HTTP.new(pds_uri.host, pds_uri.port)
          # Set read timeout to 15 seconds.
          http.read_timeout = 15
          http.use_ssl = true if pds_uri.is_a?(URI::HTTPS)
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?
          response = http.post(pds_uri.path, pds_uri.query)
          begin
            response.value
          rescue Exception => e
            raise "Error in #{self.class}. Invalid HTTP response status.\n#{e.message}"
          end
          # PDS returns as HTML content type, unfortunately.
          @response = Nokogiri.XML(response.body)
          @error = @response.at("//error").inner_text unless @response.at("//error").nil?
          # Don't raise an error, because user not found is reported as an error.
        end
      end  

      # Makes a call get-attribute with attribute "bor_info".
      # Raises an exception if there is an unexpected response.
      class BorInfo < GetAttribute

        protected
        def initialize(pds_url, calling_system, pds_handle, bor_info_attributes)
          super(pds_url, calling_system, pds_handle, "bor_info")
          raise RuntimeError.new( 
            "Error in #{self.class}."+
            "Unrecognized response: #{@response}.") unless @response.root.name.eql?("bor-info") or @response.root.name.eql?("pds")
          bor_info_attributes.each { |local_attribute, xml_attribute|
            self.class.send(:attr_reader, local_attribute)
            instance_variable_set("@#{local_attribute}".to_sym, 
              @response.at("#{xml_attribute}").inner_text) unless @response.at("//bor-info/#{xml_attribute}").nil?
          }
        end
      end
    end
  end
end