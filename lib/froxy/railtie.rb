# frozen_string_literal: true

require 'rails/railtie'

POSTCSS_CONFIG_CLI = File.expand_path('../../bin/postcss_config.js', __dir__)

module Froxy
  class Railtie < ::Rails::Railtie
    config.froxy = ActiveSupport::OrderedOptions.new

    initializer 'froxy.configuration' do |app|
      options = app.config.froxy

      options.use_proxy = true if options.use_proxy.nil?
      options.use_postcss = system(POSTCSS_CONFIG_CLI, Rails.root.to_s) if options.use_postcss.nil?
      options.use_esbuild = true if options.use_esbuild.nil?
      options.side_load_assets = true if options.side_load_assets.nil?
    end

    initializer 'froxy.proxy' do |app|
      next unless app.config.froxy.use_proxy

      app.middleware.insert_after ActionDispatch::Static, Froxy::Proxy
    end

    initializer 'froxy.side_load_assets' do |app|
      next unless app.config.froxy.side_load_assets

      ActiveSupport.on_load :action_view do
        require 'froxy/monkey/side_load_assets'
        ActionView::TemplateRenderer.prepend Froxy::Monkey::SideLoadAssets

        require 'froxy/helper'
        include Froxy::Helper
      end
    end
  end
end
