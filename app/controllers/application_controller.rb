class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: ENV.fetch('WEB_USERNAME', 'admin'), password: ENV.fetch('WEB_PASSWORD', 'secret')
end
