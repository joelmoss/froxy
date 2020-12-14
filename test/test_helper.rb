# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'bundler'
require 'minitest/autorun'

Bundler.require :default, :test

Combustion.path = 'test/internal'
Combustion.initialize! :action_controller, :action_view do
  config.hosts << 'www.example.com'
end
