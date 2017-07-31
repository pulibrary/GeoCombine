require 'open-uri'

module GeoCombine
  class Geoblacklight
    include GeoCombine::Formats
    include GeoCombine::Subjects
    include GeoCombine::GeometryTypes

    attr_reader :metadata

    GEOBLACKLIGHT_SCHEMA_VERSION = 'v2.0'

    ##
    # Initializes a GeoBlacklight object
    # @param [String] metadata be a valid JSON string document in
    # GeoBlacklight-Schema
    # @param [Hash] fields enhancements to metadata that are merged with @metadata
    def initialize(metadata, fields = {})
      @metadata = JSON.parse(metadata).merge(fields)
      @schema = nil
    end

    ##
    # Calls metadata enhancement methods for each key, value pair in the
    # metadata hash
    def enhance_metadata
      @metadata.each do |key, value|
        enhance_subjects(key, value)
        format_proper_date(key, value)
        fields_should_be_array(key, value)
        translate_geometry_type(key, value)
      end
    end

    ##
    # Returns a string of JSON from a GeoBlacklight hash
    # @return (String)
    def to_json
      @metadata.to_json
    end

    ##
    # Validates a GeoBlacklight-Schema json document
    # @return [Boolean]
    def valid?
      @schema ||= JSON.parse(open("https://raw.githubusercontent.com/geoblacklight/geoblacklight/json-ld-schema/schema/#{GEOBLACKLIGHT_SCHEMA_VERSION}/geoblacklight-schema.json").read)
      JSON::Validator.validate!(@schema, to_json, fragment: '#/definitions/dataset') &&
        spatial_validate!
    end

    def spatial_validate!
      GeoCombine::BoundingBox.from_envelope(metadata['geom']).valid?
    end

    private

    ##
    # Enhances the 'geomType' field by translating from known types
    def translate_geometry_type(key, value)
      @metadata[key] = geometry_types[value] if key == 'geomType' && geometry_types.include?(value)
    end

    ##
    # Enhances the 'subject' field by translating subjects to ISO topic
    # categories
    def enhance_subjects(key, value)
      @metadata[key] = value.map do |val|
        if subjects.include?(val)
          subjects[val]
        else
          val
        end
      end if key == 'subject'
    end

    ##
    # Formats the 'modified' to a valid valid RFC3339 date/time string
    # and ISO8601 (for indexing into Solr)
    def format_proper_date(key, value)
      @metadata[key] = Time.parse(value).utc.iso8601 if key == 'modified'
    end

    def fields_should_be_array(key, value)
      @metadata[key] = [value] if should_be_array.include?(key) && !value.kind_of?(Array)
    end

    ##
    # GeoBlacklight-Schema fields that should be type Array
    def should_be_array
      ['creator', 'distribution', 'isPartOf', 'language', 'publisher', 'source', 'spatial', 'subject', 'temporal']
    end
  end
end
