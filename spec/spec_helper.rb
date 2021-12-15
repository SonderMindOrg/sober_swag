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

##
# Custom matcher: validates that a `SoberSwag::Reporting::Input` can parse
# a given input.
RSpec::Matchers.define :parse_input do |input|
  match do |actual|
    if defined?(@parse_to)
      values_match?(@parse_to, actual.call(input))
    else
      !actual.call(input).is_a?(SoberSwag::Reporting::Report::Base)
    end
  end

  ##
  # chain: Validate that this parser can parse to a particular value.
  chain(:to) do |parse_to|
    @parse_to = parse_to
  end
end

##
# Custom matcher: validates that a `SoberSwag::Reporting::Output` can successfully output something.
RSpec::Matchers.define :serialize_output do |input|
  match do |actual|
    if defined?(@serialize_to)
      values_match?(@serialize_to, actual.serialize_report(input))
    else
      !actual.serialize_report(input).is_a?(SoberSwag::Reporting::Report::Base)
    end
  end

  ##
  # Chain: validate that the result of applying an output is a particular value.
  chain :to do |serialize_to|
    @serialize_to = serialize_to
  end
end

##
# Custom matcher: validates that a `SoberSwag::Reporting::Input` produces a report on a given input value.
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

  ##
  # Chain: validate that one of the reported problems matches a given matcher.
  chain :with_message do |message|
    @message_body = message
  end
end

##
# Custom matcher: validates that a `SoberSwag::Reporting::Output` produces a report when it tries to serialize
# a given value.
RSpec::Matchers.define :report_on_output do |input|
  match do |actual|
    result = actual.serialize_report(input)

    res = result.is_a?(SoberSwag::Reporting::Report::Base)

    if defined?(@message_body)
      res && result.full_errors.any? { |r| values_match?(@message_body, r) }
    else
      res
    end
  end

  ##
  # Chain: validate that one of the reported messages matches a matcher.
  chain :with_message do |message|
    @message_body = message
  end
end
