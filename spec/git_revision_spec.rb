# Author: Nicolas Meylan
# Date: 03.01.15
# Encoding: UTF-8
# File: git_revision_spec.rb
require_relative 'spec_helper'

describe SCMAdapter::Adapters::GitAdapter do
  describe 'revisions' do
    before(:each) do
      @git = SCMAdapter::AbstractAdapterFactory.initialize(:git, TEST_REPO_LOCATION)
    end
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
end