require 'will_paginate'
class FacebookLinkRenderer < WillPaginate::ViewHelpers::LinkRenderer
  def link(text, target, attributes = {})
    if target.is_a? Fixnum
      attributes[:rel] = rel_value(target)
      target = url(target)
    end
    target = target.gsub "/canvas","/micasasucasa"
    if target =~ /micasasucasa\?/
      target = target.gsub "micasasucasa","micasasucasa/search"
    end
    attributes[:href] = target
    tag(:a, text, attributes)
  end
end