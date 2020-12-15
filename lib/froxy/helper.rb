require 'action_view'

module Froxy
  module Helper
    include ActionView::Helpers::AssetUrlHelper

    def compute_asset_path(source, _options = {})
      File.join('', source)
    end
  end
end
