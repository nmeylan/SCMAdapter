# Author: Nicolas Meylan
# Date: 03.01.15
# Encoding: UTF-8
# File: git_diff_spec.rb
require_relative 'spec_helper'

def load_and_parse_diff_hunk(name, &block)
  @git = SCMAdapter::AbstractAdapterFactory.initialize(:git, TEST_REPO_LOCATION)
  file_content = ''
  File.open("spec_resources/git_diffs/#{name}", 'r') do |file|
    file_content = file.gets(nil)
  end
  block_given? ? yield(@git, file_content) : @git.parse_diff_hunk(file_content)
end

describe SCMAdapter::Adapters::GitAdapter do
  describe 'Gif diff' do
    before(:each) do
      @git = SCMAdapter::AbstractAdapterFactory.initialize(:git, TEST_REPO_LOCATION)
    end

    RSpec.shared_examples "a single hunk parser" do
      describe "parse a diff hunk" do
        it "parse diff_hunk file" do
          from_count = 14
          to_count = 14
          expect(diff_hunk.class).to eql(SCMAdapter::RepositoryData::DiffHunk)
          diff_hunk_header = diff_hunk.header

          expect(diff_hunk_header.class).to eql(SCMAdapter::RepositoryData::DiffHunkHeader)
          expect(diff_hunk_header.from_file_start).to eql(1336)
          expect(diff_hunk_header.from_file_count).to eql(from_count)

          expect(diff_hunk_header.to_file_start).to eql(1336)
          expect(diff_hunk_header.to_file_count).to eql(to_count)
          expect(diff_hunk_header.text).to eql(" Understanding The Method Chaining")

          from_file_content = diff_hunk.from_file_content
          from_file_expected_content = ''

          File.open('spec_resources/git_diffs/diff_hunk_from_file_content', 'r') do |file|
            from_file_expected_content = file.gets(nil)
          end
          expect(from_file_content.split(/\n/).size).to eql(from_count)
          expect(from_file_content).to eql(from_file_expected_content)

          to_file_expected_content = ''
          File.open('spec_resources/git_diffs/diff_hunk_to_file_content', 'r') do |file|
            to_file_expected_content = file.gets(nil)
          end
          to_file_content = diff_hunk.to_file_content
          expect(to_file_content.split(/\n/).size).to eql(to_count)
          expect(to_file_content).to eql(to_file_expected_content)

          expect(diff_hunk.number_additions).to eql(7)
          expect(diff_hunk.number_deletions).to eql(7)
        end

        it "parse diff_hunk_bis file" do
          from_count = 7
          to_count = 7
          expect(diff_hunk_bis.class).to eql(SCMAdapter::RepositoryData::DiffHunk)
          diff_hunk_header = diff_hunk_bis.header

          expect(diff_hunk_header.class).to eql(SCMAdapter::RepositoryData::DiffHunkHeader)
          expect(diff_hunk_header.from_file_start).to eql(1384)
          expect(diff_hunk_header.from_file_count).to eql(from_count)

          expect(diff_hunk_header.to_file_start).to eql(1384)
          expect(diff_hunk_header.to_file_count).to eql(to_count)
          expect(diff_hunk_header.text).to eql(" WHERE people.name = 'John'")

          from_file_content = diff_hunk_bis.from_file_content
          from_file_expected_content = ''

          File.open('spec_resources/git_diffs/diff_hunk_bis_from_file_content', 'r') do |file|
            from_file_expected_content = file.gets(nil)
          end
          expect(from_file_content.split(/\n/).size).to eql(from_count)
          expect(from_file_content).to eql(from_file_expected_content)

          to_file_expected_content = ''
          File.open('spec_resources/git_diffs/diff_hunk_bis_to_file_content', 'r') do |file|
            to_file_expected_content = file.gets(nil)
          end
          to_file_content = diff_hunk_bis.to_file_content
          expect(to_file_content.split(/\n/).size).to eql(to_count)
          expect(to_file_content).to eql(to_file_expected_content)

          expect(diff_hunk_bis.number_additions).to eql(1)
          expect(diff_hunk_bis.number_deletions).to eql(1)

        end
      end
    end

    describe 'single diff parser' do

      it 'parse a diff hunk header more than one line' do
        diff_hunk_header = @git.parse_diff_hunk_header('@@ -1336,14 +1336,15 @@ Understanding The Method Chaining')
        expect(diff_hunk_header.class).to eql(SCMAdapter::RepositoryData::DiffHunkHeader)
        expect(diff_hunk_header.from_file_start).to eql(1336)
        expect(diff_hunk_header.from_file_count).to eql(14)

        expect(diff_hunk_header.to_file_start).to eql(1336)
        expect(diff_hunk_header.to_file_count).to eql(15)
        expect(diff_hunk_header.text).to eql(" Understanding The Method Chaining")
      end

      it 'parse a diff hunk header one line' do
        diff_hunk_header = @git.parse_diff_hunk_header('@@ -1 +1,2 @@')
        expect(diff_hunk_header.class).to eql(SCMAdapter::RepositoryData::DiffHunkHeader)
        expect(diff_hunk_header.from_file_start).to eql(1)
        expect(diff_hunk_header.from_file_count).to eql(nil)

        expect(diff_hunk_header.to_file_start).to eql(1)
        expect(diff_hunk_header.to_file_count).to eql(2)
        expect(diff_hunk_header.text).to eql('')

        diff_hunk_header = @git.parse_diff_hunk_header('@@ -0,0 +1 @@')
        expect(diff_hunk_header.class).to eql(SCMAdapter::RepositoryData::DiffHunkHeader)
        expect(diff_hunk_header.from_file_start).to eql(0)
        expect(diff_hunk_header.from_file_count).to eql(0)

        expect(diff_hunk_header.to_file_start).to eql(1)
        expect(diff_hunk_header.to_file_count).to eql(nil)
        expect(diff_hunk_header.text).to eql('')
      end
      describe 'parse hunk' do
        before(:each) do
          @hunk = ''
          File.open('spec_resources/git_diffs/diff_hunk', 'r') do |file|
            @hunk = file.gets(nil)
          end
        end

        it_behaves_like "a single hunk parser" do

          let(:diff_hunk) { load_and_parse_diff_hunk('diff_hunk') }
          let(:diff_hunk_bis) { load_and_parse_diff_hunk('diff_hunk_bis') }
        end

        it 'raise an ArgumentError when passing wrong params to parse_hunk_content' do
          expect { @git.parse_hunk_content(:wrong_arg, '') }.to raise_error(ArgumentError)
          expect { @git.parse_hunk_content(:from, '') }.to_not raise_error
          expect { @git.parse_hunk_content(:to, '') }.to_not raise_error
        end

        it 'parse from file_content' do
          from_file_expected_content = ''
          File.open('spec_resources/git_diffs/diff_hunk_from_file_content', 'r') do |file|
            from_file_expected_content = file.gets(nil)
          end
          from_file_content, number_deletions = @git.parse_hunk_content(:from, @hunk)
          expect(from_file_content.split(/\n/).size).to eql(from_file_expected_content.split(/\n/).size)
          expect(from_file_content).to eql(from_file_expected_content)
          expect(number_deletions).to eql(7)
        end

        it 'parse to file_content' do
          to_file_expected_content = ''
          File.open('spec_resources/git_diffs/diff_hunk_to_file_content', 'r') do |file|
            to_file_expected_content = file.gets(nil)
          end
          to_file_content, number_additions = @git.parse_hunk_content(:to, @hunk)
          expect(to_file_content.split(/\n/).size).to eql(to_file_expected_content.split(/\n/).size)
          expect(to_file_content).to eql(to_file_expected_content)
          expect(number_additions).to eql(7)
        end

        it 'do not raise error when diff input is empty' do
          # Even if it should not happen
          to_file_content, number_additions = @git.parse_hunk_content(:to, '')
          expect(to_file_content).to eql('')
          expect(number_additions).to eql(0)
        end
      end

      describe 'parse multi hunks' do
        before(:each) do
          @hunks = ''
          File.open('spec_resources/git_diffs/diff_multi_hunks', 'r') do |file|
            @hunks = file.gets(nil)
          end
        end

        it_behaves_like "a single hunk parser" do
          diff_hunks = load_and_parse_diff_hunk('diff_multi_hunks') { |git, hunk| git.parse_diff_hunks(hunk) }
          let(:diff_hunk) { diff_hunks.first }
          let(:diff_hunk_bis) { diff_hunks[1] }
        end

        it 'parse two diff hunk' do
          diff_hunks = @git.parse_diff_hunks(@hunks)
          expect(diff_hunks.class).to eql(Array)
          expect(diff_hunks.size).to eql(2)
          
          total_additions = total_deletions = 0
          diff_hunks.each do |hunk|
            expect(hunk.class).to eql(SCMAdapter::RepositoryData::DiffHunk)
            total_additions += hunk.number_additions
            total_deletions += hunk.number_deletions
          end

          expect(total_additions).to eql(8)
          expect(total_deletions).to eql(8)
        end
      end
    end
  end
end