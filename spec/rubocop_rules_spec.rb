# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '.rubocop_rules.yml' do # rubocop:disable RSpec/DescribeClass
  rules_version = '3.2.3' # Update this when the rules are written with a new Ruby version

  it "has the correct rules for Ruby: #{rules_version}", skip: rules_version != RUBY_VERSION do
    # If this spec failed, it's because Rubocop rules changed and you need to run:
    # bin/lint --write-rubocop-rules
    # (and commit the updated .rubocop_rules.yml)
    `bin/lint --write-rubocop-rules`
    # Verify that the file hasn't changed
    expect(`git diff --exit-code --ignore-space-change .rubocop_rules.yml`).to eq('')
  end
end
