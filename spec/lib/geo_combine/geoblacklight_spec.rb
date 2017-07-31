require 'spec_helper'

RSpec.describe GeoCombine::Geoblacklight do
  include XmlDocs
  include JsonDocs
  include GeoCombine::Exceptions
  let(:full_geobl) { GeoCombine::Geoblacklight.new(full_geoblacklight) }
  let(:basic_geobl) { GeoCombine::Geoblacklight.new(basic_geoblacklight) }
  describe '#initialize' do
    it 'parses metadata argument JSON to Hash' do
      expect(basic_geobl.instance_variable_get(:@metadata)).to be_an Hash
    end
    describe 'merges fields argument into metadata' do
      let(:basic_geobl) { GeoCombine::Geoblacklight.new(basic_geoblacklight, '@id' => 'new one', "extra_field" => true)}
      it 'overwrites existing metadata fields' do
        expect(basic_geobl.metadata['@id']).to eq 'new one'
      end
      it 'adds in new fields' do
        expect(basic_geobl.metadata['extra_field']).to be true
      end
    end
  end
  describe '#metadata' do
    it 'reads the metadata instance variable' do
      expect(basic_geobl.metadata).to be_an Hash
      expect(basic_geobl.metadata).to have_key '@id'
    end
  end
  describe '#to_json' do
    it 'returns valid json' do
      expect(valid_json?(full_geobl.to_json)).to be_truthy
      expect(valid_json?(basic_geobl.to_json)).to be_truthy
    end
  end
  let(:enhanced_geobl) { GeoCombine::Geoblacklight.new(basic_geoblacklight, 'geomType' => 'esriGeometryPolygon') }
  before { enhanced_geobl.enhance_metadata }
  describe '#enhance_metadata' do
    it 'enhances the subject field' do
      expect(enhanced_geobl.metadata['subject']).to include 'Boundaries', 'Inland Waters'
    end
    it 'formats the date properly as ISO8601' do
      expect(enhanced_geobl.metadata['modified']).to match(/Z$/)
    end
    it 'formats the geometry type field' do
      expect(enhanced_geobl.metadata['geomType']).to eq 'Polygon'
    end
  end
  describe '#valid?' do
    it 'a valid geoblacklight-schema document should be valid' do
      expect(full_geobl.valid?).to be true
    end
    context 'must have required fields' do
      %w(
        @context
        @id
        @type
        accessLevel
        conformsTo
        geom
        provenance
        slug
        title
      ).each do |field|
        it field do
          full_geobl.metadata.delete field
          expect { full_geobl.valid? }.to raise_error(JSON::Schema::ValidationError, /#{field}/)
        end
      end
    end
    context 'need not have optional fields' do
      %w(
        creator
        description
        describedBy
        distribution
        geomType
        isPartOf
        issued
        landingPage
        language
        license
        modified
        publisher
        resourceType
        source
        spatial
        subject
        temporal
      ).each do |field|
        it field do
          full_geobl.metadata.delete field
          expect { full_geobl.valid? }.not_to raise_error
        end
      end
    end
    it 'an invalid document' do
      expect { basic_geobl.valid? }.to raise_error JSON::Schema::ValidationError
    end
    it 'validates spatial bounding box' do
      expect(JSON::Validator).to receive(:validate!).and_return true
      expect { basic_geobl.valid? }
        .to raise_error GeoCombine::Exceptions::InvalidGeometry
    end
  end
  describe 'spatial_validate!' do
    context 'when valid' do
      it { full_geobl.spatial_validate! }
    end
    context 'when invalid' do
      it { expect { basic_geobl.spatial_validate! }.to raise_error GeoCombine::Exceptions::InvalidGeometry }
    end
  end
end
