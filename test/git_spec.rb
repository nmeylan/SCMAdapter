# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: git_spec.rb

require '../lib/SCMAdapter'

describe SCMAdapter::Adapters::GitAdapter, 'instantiation' do
  it "exists" do
    git = SCMAdapter::AbstractAdapterFactory.initialize(:git, 'resources/git')

    expect(git).not_to eql(nil)
    expect(git.exists?).to eq(true)
  end

  # it "does not exists" do
  #   git = SCMAdapter::AbstractAdapterFactory.initialize(:git, 'resources/git_untracked')
  #
  #   expect(git).not_to eql(nil)
  #   expect(git.exists?).to eq(false)
  # end

end

describe SCMAdapter::Adapters::GitAdapter, 'branch' do
  BRANCH_NAMES = %w(master branch1)
  it "contains 2 branch" do
    git = SCMAdapter::AbstractAdapterFactory.initialize(:git, 'resources/git')

    expect(git).not_to eql(nil)
    expect(git.branches.size).to eq(2)
  end

  it "contains 2 branch with names" do
    git = SCMAdapter::AbstractAdapterFactory.initialize(:git, 'resources/git')

    expect(git).not_to eql(nil)
    branches = git.branches
    expect(branches.size).to eq(2)
    expect(BRANCH_NAMES.include?(branches[0].branch_name)).to eq(true)
    expect(BRANCH_NAMES.include?(branches[1].branch_name)).to eq(true)
  end

  it "has master as current branch" do
    git = SCMAdapter::AbstractAdapterFactory.initialize(:git, 'resources/git')

    expect(git).not_to eql(nil)
    branches = git.branches
    expect(branches.size).to eq(2)
    master = branches.detect { |branch| branch.branch_name.eql?('master') }
    expect(master.is_current).to eq(true)
  end

end

describe SCMAdapter::Adapters::GitAdapter, 'tag' do
  TAG_NAMES = %w(v0.1)
  it "contains 1 tag" do
    git = SCMAdapter::AbstractAdapterFactory.initialize(:git, 'resources/git')

    expect(git).not_to eql(nil)
    tags = git.tags
    expect(tags.size).to eq(1)
    expect(TAG_NAMES.include?(tags[0])).to eq(true)
  end
end