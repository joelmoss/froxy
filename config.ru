# frozen_string_literal: true

require 'rubygems'
require 'bundler'

Bundler.require :default, :development

Combustion.path = 'test/internal'
Combustion.initialize! :action_controller, :action_view
run Combustion::Application
