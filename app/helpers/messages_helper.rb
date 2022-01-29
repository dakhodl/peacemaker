module MessagesHelper
  def messaging_type_description(name)
    case name
    when "direct"
      %Q{
        Your .onion is broadcast along with this ad.
        Distant people may respond directly to you, automatically added as Low Trust peers.
        Choose this if you prefer broad reach and quick, reliable responses.
    }
    when "blinded"
      %Q{
      Your .onion remains only with your direct peers.
      Messages propagate through peers, encrypted by public key in Ad.
      Choose this if you prefer slower, network bound responses for privacy.
    }
    end
  end
end
