module AdsHelper
  def ad_trust_channel_description(name)
    case name
    when "high_trust"
      %Q{
        Only your high trust peers will share this with their high trust peers.
      }
    when "low_trust"
      %Q{
        All of your peers will share this with all of their peers.
      }
    end
  end
end
