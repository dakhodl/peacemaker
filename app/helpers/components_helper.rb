module ComponentsHelper
  def empty_state_container
    content_tag(:div, class: "w-full h-full mt-24 md:mt-36 lg:mt-0 flex flex-col items-center justify-center content-center") do
      yield
    end
  end

  def detail_sidebar
    content_tag(
      :div, 
      class: "DetailSidebar",
      'data-detail-sidebar-selected-class': "DetailSidebar__item--selected",
      'data-controller': "detail-sidebar" 
    ) do
      yield if block_given?
    end
  end

  def detail_sidebar_body
    content_tag 'turbo-frame', 
      id: "detail_view", 
      class: "DetailSidebar__body paper",
      'data-turbo-action': "advance" do
      yield if block_given?
    end
  end
end
