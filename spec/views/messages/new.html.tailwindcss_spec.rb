require 'rails_helper'

RSpec.describe "messages/new", type: :view do
  before(:each) do
    assign(:message, Message.new(
      ad: nil,
      peer: nil,
      body: "MyText"
    ))
  end

  it "renders new message form" do
    render

    assert_select "form[action=?][method=?]", messages_path, "post" do

      assert_select "input[name=?]", "message[ad_id]"

      assert_select "input[name=?]", "message[peer_id]"

      assert_select "textarea[name=?]", "message[body]"
    end
  end
end
