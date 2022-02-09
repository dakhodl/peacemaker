class Api::V1::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :http_basic_authenticate
end
