require 'rails_helper'

RSpec.describe 'Getting a person' do
  context 'with a good id' do
    let!(:person) { Person.create(first_name: 'Anthony', last_name: 'Guy') }
    let(:request) { get "/people/#{person.id}" }

    describe 'the response' do
      subject { request && response }

      it { should be_successful }
      it { should_not be_server_error }
    end

    describe 'the response body' do
      subject { request && response && JSON.parse(response.body) }

      it { should include('first_name' => 'Anthony') }
      it { should include('last_name' => 'Guy') }
    end
  end

  context 'with a bad id' do
    let(:request) { get '/people/my-awesome-guy' }

    describe 'the response' do
      subject { request && response }

      it { should_not be_successful }
      it { should_not be_server_error }
      it { should have_http_status(:bad_request) }
      it { should be_bad_request }
    end
  end
end
