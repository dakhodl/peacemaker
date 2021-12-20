require 'rails_helper'

RSpec.describe 'Api::V1::Statuses', type: :request do
  describe 'GET /show' do
    it 'renders head ok, simple peer status route' do
      get '/api/v1/status'
      expect(response).to be_successful
    end
  end
end
