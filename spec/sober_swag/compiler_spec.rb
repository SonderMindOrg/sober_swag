require 'spec_helper'

RSpec.describe SoberSwag::Compiler do
  context 'with a mapped nested output' do
    let(:output) do
      SoberSwag::OutputObject.define do
        ut = primitive(:String).via_map do |t|
          Time.at(t).iso8601
        end
        field :created_at, ut do |r|
          r.internal_data['created_at']
        end
        field :updated_at, ut.optional do |r|
          r.internal_data['updated_at']
        end
      end
    end

    it 'works without error' do
      expect {
        described_class.new.add_type(output.type)
      }.not_to raise_error
    end
  end
end
