module ComponentsHelper
  def empty_state_container
    content_tag(:div, class: "w-full h-full mt-24 md:mt-36 lg:mt-0 flex flex-col items-center justify-center content-center") do
      yield
    end
  end
end
