require 'spec_helper'

RSpec.describe GeoCombine::Csw do
  include XmlDocs
  let(:csw_object) { GeoCombine::Csw.new(simple_csw) }
  describe '#initialize' do
    it 'returns an instantiated CSW object' do
      expect(csw_object).to be_an GeoCombine::Csw
    end
  end
  describe 'dc' do
    it 'returns elements from a Dublin Core namespace' do
      expect(csw_object.dc(:identifier).map(&:text)).to eq ['RGIS::192fc31f-a713-44f2-98af-a1c8997f3e72::ISO-19115:2003']
    end

    it 'multiple elements are returned as array elements' do
      expect(csw_object.dc(:subject).map(&:text)).to eq ['Federal lands', 'Parkways', 'Rivers', 'Scenic Rivers', 'Wild and Scenic Rivers', 'United States', 'USA', 'New Mexico']
    end
  end
  describe 'dct' do
    it 'returns elements from a Dublin Core terms namespace' do
      expect(csw_object.dct(:modified).map(&:text)).to eq ['2014-06-16']
    end
    it 'multiple elements are returned in an array' do
      expect(csw_object.dct(:references).count).to eq 4
    end
  end
  describe '#to_geoblacklight' do
    it 'returns a geoblacklight object' do
      expect(csw_object.to_geoblacklight).to eq ''
    end
  end
end
