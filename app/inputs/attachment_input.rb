class AttachmentInput < Formtastic::Inputs::FileInput
  def image_html_options
    {:class => 'attachment', :style => "border-radius: 50%; box-shadow: 0 4px 7px rgba(0, 0, 0, 0.4);"}.merge(options[:image_html] || {})
  end

  def to_html
    input_wrapping do
      label_html <<
      image_html <<
      builder.file_field(method, input_html_options)
    end
  end

protected

  def image_html
    return "".html_safe if builder.object.new_record?

    url = case options[:image]
    when Symbol
      builder.object.send(options[:image])
    when Proc
      options[:image].call(builder.object)
    else
      options[:image].to_s
    end

    builder.template.image_tag(url, image_html_options).html_safe
  end
end