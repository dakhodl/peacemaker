module ComponentsHelper
  def empty_state_container
    content_tag(:div, class: "w-full h-full mt-36 flex flex-col items-center justify-center content-center") do
      yield
    end
  end
end
