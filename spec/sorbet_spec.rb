require 'rails_helper'
require 'open3'

RSpec.describe 'sorbet' do
  let!(:harry) do
    Wizard.create!(
      name: 'Harry Potter',
      house: :Gryffindor,
    )
  end
  let!(:book) do
    SpellBook.create!(
      name: 'Fantastic Beasts',
      wizard: harry,
      book_type: :biology,
    )
  end
  let!(:wand) do
    Wand.create!(
      wizard: harry,
      core_type: :phoenix_feather,
      wood_type: "holly",
    )
  end

  before(:all) do
    # only initialize sorbet once for all tests because it is slow
    stdout, stderr, status = Open3.capture3(
      {'SRB_YES' => '1'}, 'bundle', 'exec', 'srb', 'init',
      chdir: Rails.root.to_path,
    )

    stdout, stderr, status = Open3.capture3(
      'bundle', 'exec', 'srb', 'tc',
      chdir: Rails.root.to_path,
    )

    # run sorbet-rails rake tasks
    Rake::Task['rails_rbi:all'].invoke

    # Regenerate hidden-definitions because there might be conflicts between signature
    # generated by sorbet-rails & by hidden-definitions
    # They should be resolved when re-running this script
    stdout, stderr, status = Open3.capture3(
      'bundle', 'exec', 'srb', 'rbi', 'hidden-definitions',
      chdir: Rails.root.to_path,
    )

    stdout, stderr, status = Open3.capture3(
      'bundle', 'exec', 'srb', 'rbi', 'todo',
      chdir: Rails.root.to_path,
    )
  end

  it 'returns expected sorbet tc result' do
    stdout, stderr, status = Open3.capture3(
      'bundle', 'exec', 'srb', 'tc', '--typed-override=typed-override.yaml',
      chdir: Rails.root.to_path,
    )
    expected_file_path = 'expected_srb_tc_output.txt'
    expect_match_file(stderr, expected_file_path)
    expect(stdout).to eql('')
  end

  it 'passes sorbet dynamic checks' do
    file_path = Rails.root.join('sorbet_test_cases.rb')
    expect {
      load(file_path)
    }.to_not raise_error
  end

  it 'runs with srb tc --lsp' do
    stdout, stderr, status = Open3.capture3(
      'bundle', 'exec', 'srb', 'tc', '--lsp',
      chdir: Rails.root.to_path,
    )
    expect(status.exitstatus).to eql(0)
  end
end
