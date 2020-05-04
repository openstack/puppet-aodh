require 'puppet'
require 'puppet/type/aodh_api_paste_ini'

describe 'Puppet::Type.type(:aodh_api_paste_ini)' do
  before :each do
    @aodh_api_paste_ini = Puppet::Type.type(:aodh_api_paste_ini).new(:name => 'DEFAULT/foo', :value => 'bar')
  end

  it 'should accept a valid value' do
    @aodh_api_paste_ini[:value] = 'bar'
    expect(@aodh_api_paste_ini[:value]).to eq('bar')
  end

  it 'should autorequire the package that install the file' do
    catalog = Puppet::Resource::Catalog.new
    anchor = Puppet::Type.type(:anchor).new(:name => 'aodh::install::end')
    catalog.add_resource anchor, @aodh_api_paste_ini
    dependency = @aodh_api_paste_ini.autorequire
    expect(dependency.size).to eq(1)
    expect(dependency[0].target).to eq(@aodh_api_paste_ini)
    expect(dependency[0].source).to eq(anchor)
  end

end
