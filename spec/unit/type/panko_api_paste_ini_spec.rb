require 'puppet'
require 'puppet/type/panko_api_paste_ini'

describe 'Puppet::Type.type(:panko_api_paste_ini)' do
  before :each do
    @panko_api_paste_ini = Puppet::Type.type(:panko_api_paste_ini).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should accept a valid value' do
    @panko_api_paste_ini[:value] = 'bar'
    expect(@panko_api_paste_ini[:value]).to eq('bar')
  end

  it 'should autorequire the anchor that install the file' do
    catalog = Puppet::Resource::Catalog.new
    anchor = Puppet::Type.type(:anchor).new(:name => 'panko::install::end')
    catalog.add_resource anchor, @panko_api_paste_ini
    dependency = @panko_api_paste_ini.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@panko_api_paste_ini)
    expect(dependency[0].source).to eq(anchor)
  end

end
