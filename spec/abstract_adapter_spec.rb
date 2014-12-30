require_relative 'spec_helper'

describe SCMAdapter::AbstractAdapter do
  before(:each) do
    @adapter = SCMAdapter::AbstractAdapter.new('', :scm, nil)
  end

  it 'is instantiated' do
    expect(@adapter).not_to be(nil)
  end

  it 'raise NotImplementedError on revisions' do
    methods = %i(tags branches revisions version)
    methods.each do |meth|
      expect { @adapter.send(meth) }.to raise_error(NotImplementedError)
    end
    expect { @adapter.diff(nil) }.to raise_error(NotImplementedError)
  end

  it 'raise CommandFailed on handle error' do
    expect { @adapter.handle_error('There is an error') }.to raise_error(SCMAdapter::CommandFailed)
  end
end