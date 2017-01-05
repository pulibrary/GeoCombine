module GeoCombine
  class CkanMetadata
    attr_reader :metadata
    def initialize(metadata)
      @metadata = JSON.parse(metadata)
    end

    ##
    # Creates and returns a Geoblacklight schema object from this metadata
    # @return [GeoCombine::Geoblacklight]
    def to_geoblacklight
      GeoCombine::Geoblacklight.new(geoblacklight_terms.to_json)
    end

    ##
    # Builds a Geoblacklight Schema type hash from Esri Open Data portal
    # metadata
    # @return [Hash]
    def geoblacklight_terms
      {
        dc_identifier_s: @metadata['id'],
        dc_title_s: @metadata['title'],
        dc_rights_s: 'Public',
        layer_geom_type_s: 'Not Specified', # the CKAN `type` field isn't useful as it's almost always "dataset"
        dct_provenance_s: organization_name,
        dc_description_s: @metadata['notes'],
        layer_slug_s: @metadata['name'],
        solr_geom: envelope,
        dc_subject_sm: subjects
      }.select { |_k, v| !v.nil? }
    end

    def organization_name
      organization = @metadata['organization']
      (organization['name'] || organization['title']).capitalize # priority order of name, then title
    end

    def envelope
      return envelope_from_bbox unless envelope_from_bbox.nil?
      return envelope_from_spatial(',') unless envelope_from_spatial(',').nil?
      return envelope_from_spatial(' ') unless envelope_from_spatial(' ').nil?
    end

    def envelope_from_bbox
      bbox = GeoCombine::BoundingBox.new(
        west: extras('bbox-west-long'),
        south: extras('bbox-south-lat'),
        east: extras('bbox-east-long'),
        north: extras('bbox-north-lat')
      )
      begin
        return bbox.to_envelope if bbox.valid?
      rescue GeoCombine::Exceptions::InvalidGeometry
        return nil
      end
    end

    def envelope_from_spatial(delimiter)
      bbox = GeoCombine::BoundingBox.from_string_delimiter(
        extras('spatial'),
        delimiter: delimiter
      )
      begin
        return bbox.to_envelope if bbox.valid?
      rescue GeoCombine::Exceptions::InvalidGeometry
        return nil
      end
    end

    def subjects
      extras('tags').split(',').map(&:strip)
    end

    def extras(key)
      if @metadata['extras']
        @metadata['extras'].select { |h| h['key'] == key }.collect { |v| v['value'] }[0] || ''
      end
    end

    def geospatial?
      extras('metadata_type') =~ /geospatial/im
    end
  end
end
