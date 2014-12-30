require_relative 'spec_helper'

describe SCMAdapter::AbstractAdapter do
  before(:each) do
    @adapter = SCMAdapter::AbstractAdapter.new('', :scm, nil)
  end

  it 'is instantiated' do
    expect(@adapter).not_to be(nil)
  end

  it 'raise NotImplementedError merge command' do
    expect{@adapter.merge_command('log')}.to raise_error(NotImplementedError)
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

  describe 'subclass implementation' do
    before(:each) do
      @git = SCMAdapter::Adapters::GitAdapter.new('/path/to')
    end

    it 'has override command method' do
      expect(@git.class.command).to eql('git')
    end

    it 'merge command' do
      expect(@git.merge_command('log')).to eql('git log')
    end

    it 'change context with chdir' do
      Dir.stubs(:chdir).returns('/path/to')
      expect(@git.change_working_directory(&lambda{Dir.pwd})).to eql('/path/to')
    end
  end
end