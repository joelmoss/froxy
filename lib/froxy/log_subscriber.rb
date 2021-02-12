# frozen_string_literal: true

require 'active_support/log_subscriber'

module Froxy
  class LogSubscriber < ActiveSupport::LogSubscriber
    VIEWS_PATTERN = %r{^app/views/}.freeze

    def side_loaded_assets(event)
      return if (asset_types = event.payload[:asset_types]).empty?

      identifier_from_root = from_rails_root(event.payload[:identifier])

      info do
        message = +"  Side loaded #{asset_types.join(',')} for #{identifier_from_root}"
        message << " (Duration: #{event.duration.round(1)}ms | Allocations: #{event.allocations})"
      end
    end

    private

    EMPTY = ''
    def from_rails_root(string)
      string = string.sub(rails_root, EMPTY)
      string.sub!(VIEWS_PATTERN, EMPTY)
      string
    end

    def rails_root
      @rails_root ||= "#{Rails.root}/"
    end
  end
end

Froxy::LogSubscriber.attach_to :action_view
