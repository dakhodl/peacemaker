module PeersHelper
  def peer_online_status(peer)
    if peer.last_online_at.nil?
      status = 'Unknown'
      color = 'yellow'
    elsif peer.last_online_at > 10.minutes.ago
      status = 'Online'
      color = 'green'
    else
      status = 'Offline'
      color = 'red'
    end

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
  end
end
