require 'spec_helper'

RSpec.describe SoberSwag::Serializer::Base do
  it 'returns false for #lazy_type?' do
    expect(subject).not_to be_lazy_type
  end

  it 'raises an error on serialize' do
    expect { subject.serialize([]) }.to raise_error(ArgumentError)
  end

  it 'raises an error on type' do
    expect { subject.type }.to raise_error(ArgumentError)
  end

  describe '#meta' do
    subject { described_class.new.meta({ foo: :bar }) }

    it { should be_a(SoberSwag::Serializer::Meta) }
    it { should have_attributes(metadata: { foo: :bar }) }
  end
end
