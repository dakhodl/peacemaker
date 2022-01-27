class MessageThreadsController < ApplicationController
  before_action :set_message_thread, only: %i[ show update destroy ]

 # GET /message_threads or /message_threads.json
 def index
  @threads = MessageThread
    .mine
    .includes(:ad, :peer, :messages)
    .order(updated_at: :desc).all
end

# GET /message_threads/1 or /message_threads/1.json
def show
  @threads = MessageThread
    .mine
    .includes(:ad, :peer, :messages)
    .order(updated_at: :desc)
    .all
  @thread = @message_thread
end

# GET /message_threads/new or /ads/:id/message_threads/new
def new
  ad = Ad.where(uuid: params[:id]).first
  @message_thread = MessageThread.new(ad: ad, peer: ad.peer)
end

# POST /message_threads or /message_threads.json
def create
  @message_thread = MessageThread.new(message_thread_params)
  @message_thread.initialize_keys! if @message_thread.secure?
  @message_thread.initialize_peer! if @message_thread.direct?

  respond_to do |format|
    if @message_thread.save
      message = @message_thread.messages.build(body: @message_thread.body, author: :lead)
      if @message_thread.secure?
        message.type = 'Messages::LeadMessage'
        message = message.becomes(Messages::LeadMessage)
        message.encrypt_body!
      else
        message.type = 'Messages::DirectMessage'
        message = message.becomes(Messages::DirectMessage)
      end
      message.save!
      format.html { redirect_to message_thread_url(@message_thread) }
      format.json { render :show, status: :created, location: @message_thread }
    else
      format.html { render :new, status: :unprocessable_entity }
      format.json { render json: @message_thread.errors, status: :unprocessable_entity }
    end
  end
end


# DELETE /message_threads/1 or /message_threads/1.json
def destroy
  @message_thread ||= MessageThread.find(params[:id])
  @message_thread.destroy

  respond_to do |format|
    format.html { redirect_to message_threads_url }
    format.json { head :no_content }
  end
end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_message_thread
    @message_thread = MessageThread.find_by(uuid: params[:uuid])
  end

  # Only allow a list of trusted parameters through.
  def message_thread_params
    params.require(:message_thread).permit(:ad_id, :peer_id, :body)
  end
end