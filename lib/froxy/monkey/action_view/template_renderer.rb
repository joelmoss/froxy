# frozen_string_literal: true

module Froxy
  module Monkey
    module ActionView
      module TemplateRenderer
        def render_template(view, template, layout_name, locals)
          return super if template.type != :html

          # Side load layout assets - if any.
          if layout_name
            layout = find_layout(layout_name, locals.keys, [formats.first])
            layout && side_load_assets(view, layout)
          end

          # Side load view assets - if any.
          side_load_assets view, template

          super
        end

        private

        def side_load_assets(view, tpl)
          path = tpl.short_identifier.delete_suffix('.html.erb')

          instrument :side_loaded_assets, identifier: tpl.identifier, asset_types: [] do |payload|
            side_load_js path, view, payload
            side_load_css path, view, payload
          end
        end

        def side_load_js(path, view, log_payload)
          # Check that the file actually exists.
          return unless Rails.root.join(path).sub_ext('.js').exist?

          view.content_for :side_loaded_js do
            view.javascript_include_tag(path, type: :module).tap do |tag|
              !tag.nil? && (log_payload[:asset_types] << :js)
            end
          end
        end

        def side_load_css(path, view, log_payload)
          # Check that the file actually exists.
          return unless Rails.root.join(path).sub_ext('.css').exist?

          view.content_for :side_loaded_css do
            view.stylesheet_link_tag(path).tap do |tag|
              !tag.nil? && (log_payload[:asset_types] << :css)
            end
          end
        end

        def instrument(action, payload, &block)
          ActiveSupport::Notifications.instrument("#{action}.action_view", payload, &block)
        end
      end
    end
  end
end
