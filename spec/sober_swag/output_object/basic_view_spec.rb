require 'spec_helper'

RSpec.describe 'a basic SoberSwag::OutputObject with a basic view' do
  let(:target) { { id: 1, name: 'Anthony' } }
  let(:output_object) do
    SoberSwag::OutputObject.define do
      identifier 'Base'
      field :id, primitive(:Integer)
      view :complex do
        field :name, primitive(:String)
      end
    end
  end

  describe 'the returned class' do
    subject { output_object }

    it { should respond_to(:serialize) }
    it { should respond_to(:type) }

    describe 'the actual view' do
      subject { output_object.view(:complex) }

      it { should respond_to(:serialize) }
      it { should have_attributes(identifier: 'Base.Complex') }
    end
  end

  describe 'serializing' do
    context 'with the view' do
      subject do
        output_object.serialize(target, { view: :complex })
      end

      it 'raises no error' do
        expect { subject }.not_to raise_error
      end

      it { should have_key(:id) }
      it { should have_key(:name) }
      it { should eq(target) }
    end

    context 'without the view' do
      subject do
        output_object.serialize(target, {})
      end

      it { should have_key(:id) }
      it { should_not have_key(:name) }
      it { should eq({ id: 1 }) }
    end
  end

  describe 'roundtripping' do
    subject { roundtripped }

    let(:roundtripped) { output_object.type.call(serialized) }

    context 'with the view' do
      let(:serialized) { output_object.serialize(target, { view: :complex }) }

      it 'works' do
        expect { roundtripped }.not_to raise_error
      end

      it 'is the complex view type' do
        expect(subject).to be_a(output_object.view(:complex).type)
      end
    end

    context 'without the view' do
      let(:serialized) { output_object.serialize(target) }

      it 'works' do
        expect { roundtripped }.not_to raise_error
      end

      it 'is the base view type' do
        expect(subject).to be_a(output_object.view(:base).type)
      end
    end
  end
end
