class ApplicationController < ActionController::API
  rescue_from Dry::Struct::Error do
    head :bad_request
  end
end
