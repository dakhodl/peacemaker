class Api::V1::StatusController < Api::V1::BaseController
  def show
    head :ok
  end
end
