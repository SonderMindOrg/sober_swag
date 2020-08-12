require 'spec_helper'
require 'pry'
require 'pry-byebug'

RSpec.describe 'An output object with mapped fields' do
  let(:unix_timestamp) do
    SoberSwag::Serializer.primitive(:String).via_map do |input|
      Time.at(input).iso8601
    end
  end

  let(:output_object) do
    ts = unix_timestamp
    SoberSwag::OutputObject.define do
      field :start_at, ts do |o|
        o['start_at']
      end

      field :end_at, ts do |o|
        o['end_at']
      end
    end
  end

  it 'serializes' do
    expect {
      output_object.serialize({ 'start_at' => 0, 'end_at' => 1000 })
    }.not_to raise_error
  end
end
