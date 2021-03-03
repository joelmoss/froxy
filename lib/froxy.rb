# frozen_string_literal: true

require 'action_view'
require 'active_support/dependencies/autoload'

module Froxy
  extend ActiveSupport::Autoload

  autoload :Proxy
  autoload :Builder
end

require 'froxy/railtie'
