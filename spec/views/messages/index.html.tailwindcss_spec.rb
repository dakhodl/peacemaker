require 'rails_helper'

RSpec.describe "messages/index", type: :view do
  before(:each) do
    assign(:messages, [
      Message.create!(
        ad: nil,
        peer: nil,
        body: "MyText"
      ),
      Message.create!(
        ad: nil,
        peer: nil,
        body: "MyText"
      )
    ])
  end

  it "renders a list of messages" do
    render
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: "MyText".to_s, count: 2
  end
end
