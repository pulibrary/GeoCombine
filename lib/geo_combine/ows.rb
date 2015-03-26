module GeoCombine
  # Mixin to access OWS namespace in XML and do geo stuff with it
  module Ows
    ##
    # Accessor method for OWS namespace
    # @param [String, Symbol]
    # @return [Array]
    def ows(element)
      @metadata.xpath("//ows:#{element}", 'ows' => 'http://www.opengis.net/ows').children.to_a
    end

    ##
    # Generates an OGC CQL ENVELOPE(W, E, N, S)
    # @return [String]
    def bounding_box_as_envelope
      "ENVELOPE(#{lower_corner[1]}, #{upper_corner[1]}, #{upper_corner[0]}, #{lower_corner[0]})"
    end

    ##
    # Accessor method for an OWS LowerCorner that creates an array from
    # the values
    # @return [Array]
    def lower_corner
      ows('LowerCorner').first.text.split(' ')
    end

    ##
    # Accessor method for an OWS UpperCorner that creates an array from
    # the values
    # @return [Array]
    def upper_corner
      ows('UpperCorner').first.text.split(' ')
    end
  end
end
