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

  describe 'illegal mixing of reporting and non-reporting' do
    it 'raises an error when you try to do this' do
      expect {
        SoberSwag.input_object do
          identifier 'illegal'
          attribute :bar, SoberSwag::Reporting::Input::Text.new
        end
      }.to raise_error(ArgumentError, /mix reporting/)
    end
  end

  describe '.type_attribute' do
    let(:accept) do
      SoberSwag.input_object do
        identifier 'Accept'
        type_attribute 'accept'
      end
    end

    let(:reject) do
      SoberSwag.input_object do
        identifier 'Reject'
        type_attribute 'reject'
      end
    end

    let(:input) { accept | reject }

    context 'with a reject key' do
      subject { input.call(type: 'reject') }

      it { should be_a(reject) }
      its(:type) { should eq 'reject' }
    end

    context 'with an accept key' do
      subject { input.call(type: 'accept') }

      it { should be_an(accept) }
      its(:type) { should eq 'accept' }
    end
  end
end
