require "rails_helper"

RSpec.describe 'Index action for people' do
  let(:parsed_body) { request && response && JSON.parse(response.body) }
  context "with no people" do
    let(:request) { get '/people' }

    it 'is successful' do
      request
      expect(response).to be_successful
    end

    it 'is has a blank body' do
      expect(parsed_body).to be_blank
    end
  end

  context 'with a person' do
    let!(:person) { Person.create(first_name: 'Anthony', last_name: 'Guy') }

    shared_examples 'a request with the person' do
      it 'is successful' do
        request
        expect(response).to be_successful
      end

      it 'has people' do
        expect(parsed_body).to_not be_blank
      end

      it 'has the right person' do
        expect(parsed_body).to include(include('id' => person.id))
      end
    end

    context 'with a good first-name search' do
      let(:request) { get '/people', params: { first_name: 'A' } }

      it_behaves_like 'a request with the person'
    end

    context 'with a good last-name search' do
      let(:request) { get '/people', params: { last_name: 'G' } }

      it_behaves_like 'a request with the person'
    end
  end
end
