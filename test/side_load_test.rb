# frozen_string_literal: true

require 'test_helper'

class SideLoadTest < ActionDispatch::IntegrationTest
  test 'layout and view' do
    get '/'

    assert_select 'head' do
      assert_select 'link:nth(1)[href=?]', '/app/views/layouts/application.css'
      assert_select 'link:nth(2)[href=?]', '/app/views/pages/home.css'
    end
    assert_select 'body' do
      assert_select 'script:nth(1)[src=?]', '/app/views/layouts/application.js'
      assert_select 'script:nth(2)[src=?]', '/app/views/pages/home.js'
    end
  end

  test 'nothing to side load' do
    get '/nothing_to_side_load'

    refute_match '<link', response.body
    refute_match '<script', response.body
  end
end
