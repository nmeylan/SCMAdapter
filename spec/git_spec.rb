# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: git_spec.rb

require_relative 'spec_helper'

TEST_REPO_LOCATION = 'spec_resources/git_test_repo'
describe SCMAdapter::Adapters::GitAdapter, 'instantiation' do
  before(:each) do
    @git = SCMAdapter::AbstractAdapterFactory.initialize(:git, TEST_REPO_LOCATION)
  end

  it 'exits' do
    expect(@git).not_to eql(nil)
    expect(@git.exists?).to eq(true)
  end

  describe 'version' do
    it 'retrieve current git version' do
      version = @git.version
      expect(version).not_to be(nil)
    end
  end

  describe 'branch' do
    BRANCH_NAMES = %w(master branch1 branch2)
    before(:each) do
      @branches = @git.branches
    end
    it "contains 2 branch" do
      expect(@branches.size).to be >= 2
    end

    it "contains 2 branch with names" do
      expect(@branches.size).to be >= 2
      expect(@branches.collect(&:branch_name)).to match_array(BRANCH_NAMES)
    end

    it "has master as current branch" do
      expect(@branches.size).to be >= 2
      master = @branches.detect { |branch| branch.branch_name.eql?('master') }
      expect(master.is_current).to eq(true)
    end

  end

  describe 'tag' do
    TAG_NAMES = %w(v0.1)
    it "contains 1 tag" do
      tags = @git.tags
      expect(tags.empty?).not_to eq(true)
      expect(tags.size).to eq(1)
      expect(TAG_NAMES.include?(tags[0])).to eq(true)
    end
  end

  describe 'revisions parser' do
    it "parse author and date" do
      revision_txt = ''
      File.open('spec_resources/git_revisions/revision', 'r') do |file|
        revision_txt = file.gets(nil)
      end
      author, time = @git.revision_parse_author_and_date(revision_txt)
      expect(author.name).to eql('Yosuke')
      expect(author.email).to eql('yosuketto@gmail.com')
      expect(time).to eql(Time.parse('Mon Dec 29 12:29:14 2014 +0900'))
    end
    it "parse a single revision" do
      revision_txt = ''
      File.open('spec_resources/git_revisions/revision', 'r') do |file|
        revision_txt = file.gets(nil)
      end
      @revision = @git.parse_revision('50a286db529aa1d3fd050101950678854be87b61', revision_txt)
      expect(@revision.class).to eql(SCMAdapter::RepositoryData::Revision)
      expect(@revision.author.name).to eql('Yosuke')
      expect(@revision.files.size).to eql(1)
      expect(@revision.files.first[:action]).to eql('M')
    end
    it "parse multiple revisions" do
      revisions_txt = ''
      File.open('spec_resources/git_revisions/revisions', 'r') do |file|
        revisions_txt = file.gets(nil)
      end
      expected_identifiers = %w(b67b57d47368b4b834cfe8c58d9e26f5c819c154
                                50a286db529aa1d3fd050101950678854be87b61
                                e9b25eb0556f475b4e9e6bcbb1c9fb295d21c511
                                8a1d1d4e1451ae76159cd818534916d88c8b6ddc
                                73fe108d700cc2fa85bc7775c5a2ca9ca529849a)
      expected_files_for_last_rev = %w(actionpack/lib/action_controller/metal/http_authentication.rb
                                      activerecord/lib/active_record/connection_adapters/abstract/schema_definitions.rb
                                      guides/source/active_record_querying.md
                                      guides/source/association_basics.md
                                      guides/source/configuring.md
                                      guides/source/contributing_to_ruby_on_rails.md)
      @revisions = @git.parse_revisions(revisions_txt)
      expect(@revisions.size).to eql(5)
      revisions_identifiers = @revisions.collect(&:identifier)
      expect(revisions_identifiers).to eql(expected_identifiers)
      last_rev = @revisions.detect { |rev| rev.identifier.eql?('73fe108d700cc2fa85bc7775c5a2ca9ca529849a') }
      files_for_last_rev = last_rev.files
      expect(files_for_last_rev.size).to eql(expected_files_for_last_rev.size)
      expect(files_for_last_rev.collect { |hash| hash[:path] }).to match_array(expected_files_for_last_rev)
    end

    it 'generate range arguments' do
      a = 'b67b57d47368b4b834cfe8c58d9e26f5c819c154'
      b = '50a286db529aa1d3fd050101950678854be87b61'
      expect(@git.revision_specifying_range({})).to eql([])
      expect(@git.revision_specifying_range({from: a})).to match_array(["#{a}.."])
      expect(@git.revision_specifying_range({from: a, to: b})).to match_array(["#{a}..#{b}"])
      expect(@git.revision_specifying_range({includes: [a, b]})).to match_array([a, b])
      expect(@git.revision_specifying_range({excludes: [a, b]})).to match_array(["^#{a}", "^#{b}"])
      expect(@git.revision_specifying_range({includes: [a], excludes: [b]})).to match_array([a, "^#{b}"])
      expect(@git.revision_specifying_range({includes_without_ancestors: [a]})).to match_array(["#{a}^!"])
    end
  end
  describe 'revisions' do
    it "load revisions and extract a specific one with the right informations" do
      @revisions = @git.revisions
      revision = @revisions.detect { |rev| rev.identifier.eql?('a3acb858147c69f86b7ba4688884a47776b6c2aa') }
      expect(revision).not_to eql(nil)
      expect(revision.parents_identifier).to eql(%w(2c0e852bf3d1212f8c23650f9f815634f021c60e))
      expect(revision.author.name).to eql('nmeylan')
      expect(revision.author.email).to eql('nmeylan@gmail.com')
      expect(revision.time).to eql(Time.parse("Mon Dec 22 18:22:27 2014 +0100"))
      expect(revision.message).to include("Update file 1 and 2")
      expect(revision.files.size).to eql(2)
    end

    it "load revisions for a given range" do
      @revisions = @git.revisions(nil, {from: '74a2e4c6fff876a366b5249916f398f5690fd446', to: 'a440de9ad38f8571026fdf963d910988c77c5d26'})
      expect(@revisions.size).to eql(2)
      expect(@revisions[0].time).to eql(Time.parse('Mon Dec 22 14:03:25 2014 +0100'))
      expect(@revisions[1].time).to eql(Time.parse('Sun Dec 21 15:39:37 2014 +0100'))
    end

    it "load revisions for a given range and reverse result" do
      @revisions = @git.revisions(nil, {from: '74a2e4c6fff876a366b5249916f398f5690fd446', to: 'a440de9ad38f8571026fdf963d910988c77c5d26', reverse: true})
      expect(@revisions.size).to eql(2)
      expect(@revisions[1].time).to eql(Time.parse('Mon Dec 22 14:03:25 2014 +0100'))
      expect(@revisions[0].time).to eql(Time.parse('Sun Dec 21 15:39:37 2014 +0100'))
    end

    it "load revisions for a given path" do
      @revisions = @git.revisions('file1.txt')
      expect(@revisions.size).to be >= 4 # The are four commit for file1.txt at the moment (when I wrote this spec).
    end

    it "work with revisions which have more than one parent" do
      @revisions = @git.revisions
      revision = @revisions.detect { |rev| rev.identifier.eql?('1fbcfbe31a31ead054908fb92a3f9a9c8aa78f5b') }
      expect(revision.parents_identifier).to match_array(%w(a3acb858147c69f86b7ba4688884a47776b6c2aa 9d38b7bbdb0e711c3ede805a6a41f141ae9fa4ef))
    end

    it "load revisions with includes options" do
      @revisions = @git.revisions(nil, {includes: %w(a440de9ad38f8571026fdf963d910988c77c5d26)})
      expect(@revisions.size).to eql(3)
      expect(@revisions[0].identifier).to eql('a440de9ad38f8571026fdf963d910988c77c5d26')
      expect(@revisions[1].identifier).to eql(@revisions[0].parents_identifier.first)
      expect(@revisions[2].identifier).to eql('74a2e4c6fff876a366b5249916f398f5690fd446')
    end

    it "load revisions with includes without ancestors options" do
      @revisions = @git.revisions(nil, {includes_without_ancestors: %w(a440de9ad38f8571026fdf963d910988c77c5d26)})
      expect(@revisions.size).to eql(1)
      expect(@revisions[0].identifier).to eql('a440de9ad38f8571026fdf963d910988c77c5d26')
    end

    it "load revisions with includes and excludes options" do
      @revisions = @git.revisions(nil, {includes: %w(a440de9ad38f8571026fdf963d910988c77c5d26), excludes: %w(c2caf9f3c33eeed9960fb6cc0de972870b38eb0b)})
      expect(@revisions.size).to eql(1)
      expect(@revisions[0].identifier).to eql('a440de9ad38f8571026fdf963d910988c77c5d26')
    end


    it "load revisions with includes and excludes options 2" do
      @revisions = @git.revisions(nil, {includes: %w(a440de9ad38f8571026fdf963d910988c77c5d26), excludes: %w(74a2e4c6fff876a366b5249916f398f5690fd446)})
      expect(@revisions.size).to eql(2)
      expect(@revisions[0].identifier).to eql('a440de9ad38f8571026fdf963d910988c77c5d26')
      expect(@revisions[1].identifier).to eql('c2caf9f3c33eeed9960fb6cc0de972870b38eb0b')
    end
  end

  describe 'diff' do
    # it 'load diff for a given commit with its parents' do
    #   @diff = @git.diff('a440de9ad38f8571026fdf963d910988c77c5d26')
    #   expect(@diff).not_to be nil
    # end
  end
end