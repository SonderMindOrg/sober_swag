require 'spec_helper'

RSpec.describe SoberSwag::InputObject do
  describe 'setting attributes with blocks' do
    %i[attribute attribute?].each do |key|
      context "with ##{key}" do
        it 'throws an error when a non-struct parent type is given' do
          expect {
            Class.new(described_class) do
              identifier 'Test'
              public_send(key, :foo, SoberSwag::Types::Array) { attribute :foo, SoberSwag::Types::Integer }
            end
          }.to raise_error(ArgumentError)
        end

        it 'works when no parent type is given' do
          expect {
            Class.new(described_class) do
              identifier 'Test'
              public_send(key, :foo) { attribute :foo, SoberSwag::Types::Integer }
            end
          }.not_to raise_error
        end

        it 'works when another struct is given' do
          other = Class.new(described_class) do
            identifier 'Nest'
            attribute :foo, SoberSwag::Types::String
          end
          expect {
            Class.new(described_class) do
              identifier 'Parent'
              public_send(key, :foo, other) { attribute :bar, SoberSwag::Types::Integer }
            end
          }.not_to raise_error
        end
      end
    end
  end
end
