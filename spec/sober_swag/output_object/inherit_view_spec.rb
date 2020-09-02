require 'spec_helper'

RSpec.describe 'An output object that uses view inheritance' do
  context 'when inheriting base' do
    let(:output) do
      SoberSwag::OutputObject.define do
        field :name, primitive(:String)

        view :detail, inherits: :base do
          field :title, primitive(:String)
        end
      end
    end

    specify { expect { output }.not_to raise_error }

    it 'serializes everything' do
      res = Struct.new(:name, :title).new(name: 'Rich Evans', title: 'King')
      expect(output.serialize(res, view: :detail)).to eq(res.to_h)
    end
  end

  context 'when inheriting a view that does not exist' do
    let(:output) do
      SoberSwag::OutputObject.define do
        field :name, primitive(:String)
        view :detail, inherits: :nothing do
          field :title, primitive(:String)
        end
      end
    end

    specify { expect { output }.to raise_error(ArgumentError).with_message(match(/nothing/)) }
  end

  context 'when inheriting another view' do
    let(:output) do
      SoberSwag::OutputObject.define do
        field :name, primitive(:String)
        view :detail do
          field :title, primitive(:String)
        end

        view :super_detail, inherits: :detail do
          field :age, primitive(:Integer)
        end
      end
    end

    specify { expect { output }.not_to raise_error }

    it 'serializes' do
      o = Struct.new(:name, :title, :age).new('Rich Evans', 'King', 70)
      expect(output.serialize(o, view: :super_detail)).to eq(o.to_h)
    end
  end
end
