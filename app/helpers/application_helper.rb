module ApplicationHelper
  def nav_link_to(link_path, path_controller_name, &block)
    current_page_style = controller_name == path_controller_name ? 'bg-white text-gray-900' : 'text-white'
    link_to link_path,
            class: "#{current_page_style} flex flex-col grow lg:grow-0 lg:py-12 justify-center p-5 items-center font-medium", &block 
  end

  def marketplace_nav_controller
    if @ad&.peer.present?
      "ads"
    elsif controller_name == 'messages' && action_name == 'new' && @message.ad.present?
      "messages"
    else
      "marketplace"
    end
  end

  def ads_nav_controller
    if @ad&.peer.present?
      "marketplace"
    else
      "ads"
    end
  end

  def messages_nav_controller
    if controller_name == 'messages' && action_name == 'new' && @message.ad.present?
      "unselected"
    else
      "messages"
    end
  end
end
