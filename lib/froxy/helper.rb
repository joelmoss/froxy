require 'action_view'

module Froxy
  module Helper
    include ActionView::Helpers::AssetUrlHelper

    ASSET_PUBLIC_DIRECTORIES = {
      javascript: '/froxy',
      stylesheet: '/froxy'
    }.freeze

    def compute_asset_path(source, options = {})
      dir = ASSET_PUBLIC_DIRECTORIES[options[:type]] || ''
      File.join(dir, source)
    end
  end
end
