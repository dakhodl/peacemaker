module ApplicationHelper
  def nav_link_to(link_path, path_controller_name, &block)
    current_page_style = controller_name == path_controller_name ? 'border-indigo-500 text-gray-900' : ''
    link_to link_path,
            class: "#{current_page_style} inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium border-transparent border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700", &block
  end
end
