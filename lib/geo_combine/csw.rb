module GeoCombine
  class Csw < Metadata
    include GeoCombine::Ows

    def to_geoblacklight
      {
        'uuid' => dc(:identifier).map(&:text).first,
        'dc_identifier_s' => dc(:identifier).map(&:text).first,
        'dc_title_s' => dc(:title).map(&:text).first,
        'dc_description_s' => dct(:abstract).map(&:text).first,
        'dct_provenance_s' => dc(:provenance).map(&:text).first,
        'dc_subject_sm' => dc(:subject).map(&:text).join(', '),
        'dc_language_s' => dc(:language).map(&:text).first,
        'solr_geom' => bounding_box_as_envelope,
        'dct_provenance_s' => dc(:contributor).map(&:text).first
      }
    end
  end
end
