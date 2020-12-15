# frozen_string_literal: true

require 'test_helper'

class SideLoadTest < ActionDispatch::IntegrationTest
  test 'layout' do
    get '/'

    assert_match '<link rel="stylesheet" media="screen" href="/app/views/layouts/application.css" />',
                 response.body
    assert_match '<script src="/app/views/layouts/application.js"></script>',
                 response.body
  end

  test 'nothing to side load' do
    get '/nothing_to_side_load'

    refute_match '<link', response.body
    refute_match '<script', response.body
  end
end
