class StaticController < ApplicationController
  PEER = "ketl5jpyumskseiw6yq6vddb5wjtxhpkx7jvxbbejbyd2vhmtpkncaid.onion".freeze
  def index
    res = Tor::HTTP.get(PEER, "/?ping=#{params[:ping]}", 3000)
    # p res.code
    @peer_response = res.body
  end
end