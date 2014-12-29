require_relative 'spec_helper'
describe SCMAdapter::AbstractAdapter do
  it 'it instantiate a GitAdapter' do
    adapter = SCMAdapter::AbstractAdapterFactory.initialize(:git, '/path/to')
    expect(adapter.class).to be(SCMAdapter::Adapters::GitAdapter)
  end

  it 'it instantiate a HgAdapter' do
    adapter = SCMAdapter::AbstractAdapterFactory.initialize(:hg, '/path/to')
    expect(adapter.class).to be(SCMAdapter::Adapters::HgAdapter)
  end

  it 'it instantiate a SvnAdapter' do
    adapter = SCMAdapter::AbstractAdapterFactory.initialize(:svn, '/path/to')
    expect(adapter.class).to be(SCMAdapter::Adapters::SvnAdapter)
  end

  it 'it raise ArgumentError' do
    expect { SCMAdapter::AbstractAdapterFactory.initialize(:nothing, '/path/to') }.to raise_error(ArgumentError)
  end

end