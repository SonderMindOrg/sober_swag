require 'spec_helper'

RSpec.describe 'a basic SoberSwag::OutputObject' do
  let(:output_object) do
    SoberSwag::OutputObject.define do
      identifier 'BasicOutputObject'
      type_key 'basic_output_object'

      field :id, primitive(:Integer)
      field :name, primitive(:String)
    end
  end

  it 'is a class' do
    expect(output_object).to respond_to(:serialize) & respond_to(:type)
  end

  it 'has a Base constant defined' do
    expect(output_object).to have_attributes(identifier: 'BasicOutputObject')
  end

  it 'serializes without error' do
    expect {
      output_object.serialize({ id: 1, name: 'Anthony' })
    }.not_to raise_error
  end

  it 'serializes properly' do
    expect(output_object.serialize({ id: 1, name: 'Anthony' })).to eq(id: 1, name: 'Anthony', type: 'basic_output_object')
  end

  describe 'roundtripping' do
    let(:roundtripped) do
      output_object.type.new(output_object.serialize({ id: 1, name: 'Anthony' }))
    end

    it 'works' do
      expect { roundtripped }.not_to raise_error
    end

    it 'is the right type' do
      expect(roundtripped).to be_a(output_object.base.type)
    end
  end

  describe 'bad definitions' do
    it 'does not allow you to use a SoberSwag::Reporting::Output as a field def' do
      expect {
        SoberSwag::OutputObject.define do
          field :foo, SoberSwag::Reporting::Output.text
        end
      }.to raise_error(ArgumentError, /non-reporting/)
    end
  end
end
