require 'spec_helper'

RSpec.describe SoberSwag::Controller::Route do
  context 'with a basic block' do
    let(:route) do
      described_class.new(:get, :show, '/things/{id}').tap do |route|
        route.path_params do
          attribute :id, SoberSwag::Types::Params::Integer
        end

        route.summary('Basic show')
        route.description('It shows a thing')
      end
    end

    describe 'the route itself' do
      subject { route }

      it { should have_attributes(summary: 'Basic show') }
      it { should have_attributes(description: 'It shows a thing') }
      it { should have_attributes(action_module: be_a(Module)) }
      it { should have_attributes(action_module_name: 'Show') }
      it { should_not be_query_params }
      it { should_not be_request_body }
      it { should be_path_params }
    end

    describe 'the action module' do
      subject { route.action_module }

      it { should be_const_defined(:PathParams) }

      it 'generates a Dry::Struct for PathParams' do
        expect(subject::PathParams.ancestors).to include(Dry::Struct)
      end

      it 'uses the right struct for path params' do
        expect(subject::PathParams).to eq(route.path_params_class)
      end
    end
  end
end
