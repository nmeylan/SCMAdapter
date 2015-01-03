# Author: Nicolas Meylan
# Date: 21.12.14
# Encoding: UTF-8
# File: git_spec.rb

require_relative 'spec_helper'


describe SCMAdapter::Adapters::GitAdapter, 'basics' do
  before(:each) do
    @git = SCMAdapter::AbstractAdapterFactory.initialize(:git, TEST_REPO_LOCATION)
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



end