module HomeHelper

  def tab_link_to(name, options)
    html_options = {}
    html_options.update(:class => "active") if current_page?(options)
    content_tag(:li, link_to_unless_current(name, options), html_options)
  end
end
