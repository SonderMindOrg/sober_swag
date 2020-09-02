require 'spec_helper'

RSpec.describe SoberSwag::Types::CommaArray do
  describe 'parsing' do
    context 'with a param integer' do
      let(:type) { described_class.of(SoberSwag::Types::Params::Integer) }

      shared_examples 'a good run' do
        it { should eq([1, 2, 3]) }
        specify { expect { subject }.not_to raise_error }
      end

      context 'with a good string' do
        subject { type.call('1,2,3') }

        it_behaves_like 'a good run'
      end

      context 'with a good array of strings' do
        subject { type.call(%w[1 2 3]) }

        it_behaves_like 'a good run'
      end

      context 'with a good array of integers' do
        subject { type.call([1, 2, 3]) }

        it_behaves_like 'a good run'
      end

      context 'with an empty string' do
        subject { type.call('') }

        specify { expect { subject }.not_to raise_error }
        it { should be_empty }
        it { should be_a(Array) }
      end

      context 'with a bad string' do
        subject { type.call('no') }

        specify { expect { subject }.to raise_error(Dry::Types::CoercionError) }
      end
    end

    context 'with a sort-like enum' do
      let(:type) { described_class.of(SoberSwag::Types::String.enum('created_at', 'updated_at', '-created_at', '-updated_at')) }

      context 'with an empty string' do
        subject { type.call('') }

        specify { expect { subject }.not_to raise_error }
        it { should be_empty }
        it { should be_a(Array) }
        it { should eq([]) }
      end

      context 'with a sort-ish string' do
        subject { type.call('created_at, -updated_at') }

        specify { expect { subject }.not_to raise_error }
        it { should eq(%w[created_at -updated_at]) }
      end
    end
  end
end
