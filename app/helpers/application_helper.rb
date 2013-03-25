module ApplicationHelper
  
  def application_title
    'Last Post Time'
  end

  def render_page_title(title_text = "")
    (@page_title ? title_text + @page_title : title_text).gsub(/[|>-]/, "&#187;")
  end
end
