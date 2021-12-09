##
# Standard application controller.
class ApplicationController < ActionController::API
  rescue_from Dry::Struct::Error do
    head :bad_request
  end

  rescue_from SoberSwag::Reporting::Report::Error do |error|
    render json: error.report.path_hash, status: :bad_request
  end
end
