# frozen_string_literal: true
ActiveadminAddons.setup do |config|
  # Change to "default" if you want to use ActiveAdmin's default select control.
  config.default_select = "select2"

  # Set default options for DateTimePickerInput. The options you can provide are the same as in
  # xdan's datetimepicker library (https://github.com/xdan/datetimepicker/tree/2.5.4). Yo need to
  # pass a ruby hash, avoid camelCase keys. For example: use min_date instead of minDate key.
  # config.datetime_picker_default_options = {}

  # Set DateTimePickerInput input format. This if for backend (Ruby)
  # config.datetime_picker_input_format = "%Y-%m-%d %H:%M"
end

# Fix that prevents activeadmin_addons from making activeadmin_dynamic_fields not work
Rails.application.reloader.to_prepare do
  # Fixes regression in this bug: https://github.com/platanus/activeadmin_addons/issues/371
  class ActiveAdmin::Inputs::SelectInput < Formtastic::Inputs::SelectInput
    alias addons_input_html_options input_html_options

    def input_html_options
      input_html = super
      data = input_html.fetch(:data, {}).reverse_merge(addons_input_html_options[:data])

      input_html.merge(data: data)
    end
  end
end
