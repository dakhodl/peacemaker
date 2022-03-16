module PeersHelper
  def peer_online_status(peer, type: :large)
    if peer.last_online_at.nil?
      status = 'Unknown'
      color = 'yellow'
      circleColor = '#EF4444'
    elsif peer.last_online_at > 10.minutes.ago
      status = 'Online'
      color = 'green'
      circleColor = '#22C55E'
    else
      status = 'Offline'
      color = 'rose'
      circleColor = '#DC2626'
    end

    if type == :large
      tag.span(
        class: "inline-flex items-center px-2.5 py-0.5 rounded-md text-sm font-medium bg-#{color}-100 text-#{color}-800",
        "data-tooltip": "Last seen:  #{status == 'Unknown' ? 'Never' : time_ago_in_words(peer.last_online_at) + ' ago'}",
        'aria-label': "Connection status for #{peer.name}"
      ) do
        concat(tag.svg(class: "-ml-0.5 mr-1.5 h-2 w-2 text-#{color}-400", fill: 'currentColor', viewBox: '0 0 8 8') do
          tag.circle cx: '4', cy: '4', r: '3'
        end)
        concat status
      end
    else
      tag.svg(class: " mr-1 h-2 w-2", fill: circleColor, viewBox: '0 0 8 8') do
        tag.circle cx: '4', cy: '4', r: '3'
      end
    end
  end

  def peer_ads_in(timeframe: 30.days.ago..Time.current)
    @peer.ads.where(created_at: timeframe).count
  end

  def peer_onion_short(peer)
    "#{peer.onion_address[..5]}...#{peer.onion_address[-13..]}"
  end

  def peer_trust_levels
    if action_name == 'edit'
      Peer.trust_levels.to_a.reverse  
    else
      Peer.trust_levels.to_a.reject {|name, value| name === 'banned' }.reverse
    end
  end

  def peer_trust_level_description(name)
    case name
    when "high_trust"
      "Tell your peers you really trust ads from this person."
    when "low_trust"
      "Tell your peers to you do not know this person too well."
    when "banned"
      "All communication is blocked."
    end
  end
end
