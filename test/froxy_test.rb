# frozen_string_literal: true

require 'test_helper'

class FroxyTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Froxy::VERSION
  end

  def test_postcss
    assert Rails.application.config.froxy.use_postcss
  end
end
