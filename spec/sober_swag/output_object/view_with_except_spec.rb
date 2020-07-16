require 'spec_helper'

RSpec.describe 'A SoberSwag::OutputObject with a view that uses except' do
  let(:target) { { id: 1, name: 'Anthony' } }
  let(:output_object) do
    SoberSwag::OutputObject.define do
      identifier 'Base'
      field :id, primitive(:Integer)
      view :only_name do
        except! :id
        field :name, primitive(:String)
      end
    end
  end

  describe 'the output_object' do
    subject { output_object }

    it { should respond_to(:serialize) }
    it { should respond_to(:type) }
    it { should have_attributes(type: be_a(Dry::Struct::Sum)) }
  end

  describe 'serializing' do
    context 'with the view' do
      subject { output_object.serialize(target, { view: :only_name }) }

      it { should be_a(Hash) }
      it { should have_key(:name) }
      it { should_not have_key(:id) }

      it 'roundtrips' do # rubocop:disable RSpec/MultipleExpectations
        expect { output_object.type.call(subject) }.not_to raise_error
        expect(output_object.type.call(subject)).to be_a(output_object.view(:only_name).type)
      end
    end

    context 'without the view' do
      subject { output_object.serialize(target) }

      it { should be_a(Hash) }
      it { should have_key(:id) }
      it { should_not have_key(:name) }

      it 'roundtrips' do # rubocop:disable RSpec/MultipleExpectations
        expect { output_object.type.call(subject) }.not_to raise_error
        expect(output_object.type.call(subject)).to be_a(output_object.base.type)
      end
    end
  end
end
