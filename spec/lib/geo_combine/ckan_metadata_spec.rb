require 'spec_helper'

RSpec.describe GeoCombine::CkanMetadata do
  include JsonDocs
  let(:ckan_sample) { GeoCombine::CkanMetadata.new(ckan_metadata) }
  describe '#to_geoblacklight' do
    it 'returns a GeoCombine::Geoblacklight' do
      expect(ckan_sample.to_geoblacklight).to be_an GeoCombine::Geoblacklight
    end
  end
  describe '#geoblacklight_terms' do
    describe 'builds a hash which maps metadata' do
      context 'geospatial metadata' do
        it 'is geospatial metadata' do
          expect(ckan_sample.geospatial?).to be_truthy
        end
        it 'with dc_identifier_s' do
          expect(ckan_sample.geoblacklight_terms).to include(dc_identifier_s: '0009a4da-24ad-4d86-917b-1d1a1b1a67f3')
        end
        it 'with dc_title_s' do
          expect(ckan_sample.geoblacklight_terms).to include(dc_title_s: 'Cloud amount/frequency, NITRATE and other data from THOMAS G. THOMPSON in the NW Pacific, Gulf of Alaska and NE Pacific from 1967-02-05 to 1975-10-09 (NCEI Accession 8600315)')
        end
        it 'with dc_rights_s' do
          expect(ckan_sample.geoblacklight_terms).to include(dc_rights_s: 'Public')
        end
        it 'with dct_provenance_s' do
          expect(ckan_sample.geoblacklight_terms).to include(dct_provenance_s: 'Noaa-gov')
        end
        it 'with layer_slug_s' do
          expect(ckan_sample.geoblacklight_terms).to include(layer_slug_s: 'water-depth-and-other-data-from-thomas-g-thompson-and-other-platforms-from-gulf-of-alaska-and-o')
        end
        it 'with solr_geom' do
          expect(ckan_sample.geoblacklight_terms).to include(solr_geom: 'ENVELOPE(-158.2, -105.7, 59.2, 8.9)')
        end
        it 'with layer_geom_type_s' do
          expect(ckan_sample.geoblacklight_terms).to include(layer_geom_type_s: 'Not Specified')
        end
        it 'with dc_subject_sm' do
          expect(ckan_sample.geoblacklight_terms[:dc_subject_sm].length).to eq 63
        end
      end
      context 'non-geospatial-metadata' do
        let(:ckan_sample) { GeoCombine::CkanMetadata.new(ckan_metadata_non_geospatial) }
        it 'is geospatial metadata' do
          expect(ckan_sample.geospatial?).not_to be_truthy
        end
      end
    end
  end
end
