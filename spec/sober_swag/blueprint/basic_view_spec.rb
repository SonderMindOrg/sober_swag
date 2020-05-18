require 'spec_helper'

RSpec.describe 'a basic SoberSwag::Blueprint with a basic view' do
  let(:blueprint) do
    SoberSwag::Blueprint.define do
      field :id, primitive(:Integer)
      view :complex do
        field :name, primitive(:String)
      end
    end
  end

  describe 'the returned class' do
    subject { blueprint }
    it { should be_a(Class) }
    it { should be_const_defined(:Base) }
    it { should be_const_defined(:Complex) }
  end

  describe 'serializing' do
    let(:target) { { id: 1, name: 'Anthony' } }
    context 'with the view' do
      subject {
        blueprint.new.serialize(target, { view: :complex })
      }
      it 'raises no error' do
        expect { subject }.to_not raise_error
      end
      it { should have_key(:id) }
      it { should have_key(:name) }
      it { should eq(target) }
    end

    context 'without the view' do
      subject {
        blueprint.new.serialize(target, {})
      }
      it { should have_key(:id) }
      it { should_not have_key(:name) }
      it { should eq({ id: 1 }) }
    end
  end
end
