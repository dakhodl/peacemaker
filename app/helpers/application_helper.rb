module ApplicationHelper
  def nav_link_to(link_path)
    current_page_style = current_page?(link_path) ? 'border-indigo-500 text-gray-900' : ''
    link_to link_path, class: "#{current_page_style} inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium border-transparent border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700" do
      yield
    end
  end
end
