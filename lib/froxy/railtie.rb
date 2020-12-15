# frozen_string_literal: true

require 'rails/railtie'
require 'froxy/proxy'
require 'froxy/helper'

module Froxy
  class Railtie < ::Rails::Railtie
    initializer 'froxy' do |app|
      app.middleware.insert_before ActionDispatch::Static, Froxy::Proxy
    end

    ActiveSupport.on_load :action_view do
      require 'froxy/monkey/action_view/template_renderer'
      ActionView::TemplateRenderer.prepend Froxy::Monkey::ActionView::TemplateRenderer

      include Froxy::Helper
    end
  end
end
