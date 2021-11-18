# frozen_string_literal: true

require 'bundler/setup'
if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

require 'sober_swag'
require 'rspec/its'
require 'pry'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
    c.include_chain_clauses_in_custom_matcher_descriptions = true
  end
end

RSpec::Matchers.define :parse_input do |input|
  match do |actual|
    if defined?(@parse_to)
      values_match?(@parse_to, actual.call(input))
    else
      !actual.call(input).is_a?(SoberSwag::Reporting::Report::Base)
    end
  end

  chain(:to) do |parse_to|
    @parse_to = parse_to
  end
end

RSpec::Matchers.define :report_on_input do |input|
  match do |actual|
    result = actual.call(input)

    res = result.is_a?(SoberSwag::Reporting::Report::Base)

    if defined?(@message_body)
      res && result.full_errors.any? { |r| values_match?(@message_body, r) }
    else
      res
    end
  end

  chain :with_message do |message|
    @message_body = message
  end
end
