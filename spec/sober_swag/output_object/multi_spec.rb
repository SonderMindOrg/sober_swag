require 'spec_helper'

RSpec.describe 'using #multi on an output object' do
  context 'when used direclty on the object' do
    let(:output) do
      SoberSwag::OutputObject.define do
        identifier 'MyObject'
        multi %i[first_name last_name], primitive(:String)
      end
    end

    it 'serializes properly' do
      expect(output.serialize({ first_name: 'foo', last_name: 'bar' })).to eq({ first_name: 'foo', last_name: 'bar' })
    end

    specify { expect { output }.not_to raise_error }
  end

  context 'when used on a view' do
    let(:output) do
      SoberSwag::OutputObject.define do
        identifier 'Test'
        field :rank, primitive(:Integer)
        view(:detail) { multi %i[first_name last_name], primitive(:String) }
      end
    end

    it 'serializes' do
      res = { rank: 1, first_name: 'rich', last_name: 'evans' }
      expect(output.serialize(res, view: :detail)).to eq(res)
    end

    specify { expect { output }.not_to raise_error }
  end
end
