# frozen_string_literal: true
class CheckboxImageInput < Formtastic::Inputs::CheckBoxesInput
  # include CloudinaryHelper
  # f.input :products, as: :checkbox_image, :collection => product_selection
  # https://stackoverflow.com/questions/52260704/add-an-image-next-to-a-checkbox-label-in-activeadmin-form

  def choice_html(choice)
    template.content_tag(
    :label,
    img_tag(choice) + checkbox_input(choice) + choice_label(choice),
    label_html_options.merge(for: choice_input_dom_id(choice), class:     "input_with_thumbnail"))
 end

  def img_tag(choice)
    cl_image_tag(Product.find(choice[1]).photos[0].path, width: 30,
    crop: "scale")
  end
end
