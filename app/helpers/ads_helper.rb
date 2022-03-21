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

  def ad_trust_channel_icon(name)
    content_tag(:div, class: "overflow-visible relative", 'data-tooltip': name.humanize) do
      case name
      when "high_trust"
        icon_shield_check
      when "low_trust"
        icon_shield_exclamation
      end
    end
  end

end
