require 'rails_helper'

RSpec.describe 'people controller create', type: :request do
  let(:request) { post '/people', params: params }

  context 'with good params' do
    let(:params) { { person: { first_name: 'Anthony', last_name: 'Guy' } } }

    describe 'the effects of the request' do
      subject { proc { request } }

      it { should change(Person, :count).by(1) }
      it { should change(Person.where(first_name: 'Anthony'), :count).by(1) }
    end

    describe 'the response' do
      it 'is successful' do
        request
        expect(response).to be_successful
      end

      it 'returns the person' do
        request
        expect(JSON.parse(response.body)).to include('first_name' => 'Anthony')
      end
    end
  end

  context 'with bad params' do
    let(:params) { { person: { first_name: '', last_name: '' } } }

    describe 'the response' do
      subject { request && response }

      it { should_not be_successful }
      it { should_not be_server_error }
      it { should be_bad_request }
      it { should have_attributes(status: 400) }
    end

    describe 'the act of requesting' do
      subject { proc { request } }

      it { should_not change(Person, :count) }
    end

    describe 'the response body' do
      subject { request && response && JSON.parse(response.body) }

      it { should have_key('$.person.first_name') }
    end
  end
end
