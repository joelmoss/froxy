# frozen_string_literal: true

require 'froxy/version'
require 'froxy/log_subscriber'
require 'froxy/railtie'

module Froxy
  mattr_accessor :esbuild
  @@esbuild = true
end
