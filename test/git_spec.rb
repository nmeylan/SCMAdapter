# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: git_spec.rb

require '../lib/SCMAdapter'

describe SCMAdapter::Adapters::GitAdapter, 'instanciation' do
  it "is instanciate" do
    git = SCMAdapter::AbstractAdapterFactory.initialize(:git, 'resources/git')

    expect(git).not_to eql(nil)
    git.status
    expect(git.failed?).to eq(false)
  end

end

