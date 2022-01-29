class MessagesController < ApplicationController
  before_action :set_message, only: %i[ show edit update destroy ]

  # GET /messages or /messages.json
  def index
    @threads = MessageThread.includes(:ad, :peer, :messages).order(updated_at: :desc).all
  end

  # GET /messages/1 or /messages/1.json
  def show
    @threads = MessageThread.includes(:ad, :peer, :messages).order(updated_at: :desc).all
    @thread = @message.message_thread
  end

  # GET /messages/new or /ads/:id/messages/new
  def new
    @message = Message.new(ad: Ad.where(uuid: params[:id]).first)
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages or /messages.json
  def create    
    @message_thread = MessageThread.find_by(uuid: params[:uuid])
    @message = message_class.new(message_params.merge(author: @message_thread.ad.self_authored? ? :advertiser : :lead))
    @message.encrypt_body! if @message_thread.blinded?

    respond_to do |format|
      if @message.save
        format.html { redirect_to message_thread_url(@message_thread) }
        format.json { render :show, status: :created, location: @message }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1 or /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to message_url(@message) }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1 or /messages/1.json
  def destroy
    @message ||= MessageThread.find(params[:id])
    @message.destroy

    respond_to do |format|
      format.html { redirect_to messages_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find_by(uuid: params[:id])
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.require(:message).permit(:ad_id, :peer_id, :message_thread_id, :body)
    end

    def message_class
      if @message_thread.blinded? && @message_thread.ad.self_authored? 
        Messages::AdvertiserMessage
      elsif @message_thread.blinded? && !@message_thread.ad.self_authored?
        Messages::LeadMessage
      else
        Messages::DirectMessage
      end
    end
end
