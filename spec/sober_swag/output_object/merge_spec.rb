require 'spec_helper'

RSpec.describe 'merging SoberSwag output objects' do
  let(:base) do
    SoberSwag::OutputObject.define do
      identifier 'MyObject'
      field :id, primitive(:Integer)
      field :name, primitive(:String)
    end
  end

  context 'when merged into a blueprint' do
    context 'without exceptions' do
      subject { example.serialize({ id: 10, name: 'Bob', items: 10 }) }

      let(:example) do
        bp = base
        SoberSwag::OutputObject.define do
          merge bp

          field :items, primitive(:Integer)
        end
      end

      specify { expect { subject }.not_to raise_error }
      it { should have_key(:id) }
      it { should have_key(:name) }
      it { should have_key(:items) }
    end

    context 'with exceptions' do
      subject { example.serialize({ id: 10, name: 'Bob', items: 10 }) }

      let(:example) do
        bp = base
        SoberSwag::OutputObject.define do
          merge(bp, { except: [:id] })

          field :items, primitive(:Integer)
        end
      end

      specify { expect { subject }.not_to raise_error }
      it { should_not have_key(:id) }
      it { should have_key(:name) }
      it { should have_key(:items) }
    end
  end

  context 'when merged into a view' do
    let(:target) { { id: 10, name: 'Bob', items: 10 } }
    let(:example) do
      bp = base
      SoberSwag::OutputObject.define do
        field :items, primitive(:Integer)

        view :detail do
          merge bp
        end
      end
    end

    context 'when used with the view' do
      subject { example.serialize(target, view: :detail) }

      specify { expect { subject }.not_to raise_error }

      it { should have_key(:name) }
      it { should have_key(:items) }
      it { should have_key(:id) }
    end

    context 'when used without the view' do
      subject { example.serialize(target) }

      specify { expect { subject }.not_to raise_error }

      it { should have_key(:items) }
      it { should_not have_key(:name) }
      it { should_not have_key(:id) }
    end
  end
end
