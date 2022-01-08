module ApplicationHelper
  def nav_link_to(link_path, path_controller_name, &block)
    current_page_style = controller_name == path_controller_name ? 'border-indigo-500 text-gray-900 border-b-2' : 'border-transparent text-gray-500'
    link_to link_path,
            class: "#{current_page_style} inline-flex items-center px-1 pt-1 text-sm font-medium hover:border-b-2 hover:border-gray-300 hover:text-gray-700", &block 
  end

  def mobile_nav_link_to(link_path, path_controller_name, &block)
    current_page_style = controller_name == path_controller_name ? 'bg-indigo-50 border-indigo-500 text-indigo-700' : "border-transparent text-gray-500 hover:bg-gray-50 hover:border-gray-300 hover:text-gray-700"
    link_to link_path,
      class: "#{current_page_style} block pl-3 pr-4 py-2 border-l-4 text-base font-medium sm:pl-5 sm:pr-6", &block
  end
end
