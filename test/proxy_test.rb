# frozen_string_literal: true

require 'test_helper'

class ProxyTest < ActionDispatch::IntegrationTest
  test 'stylesheet' do
    get '/app/views/layouts/application.css'

    assert_equal 'text/css', response.headers['Content-Type']
    assert_match "body {\n  color: red;\n}\n", response.body
  end

  test 'javascript' do
    get '/app/views/layouts/application.js'

    assert_equal 'application/javascript', response.headers['Content-Type']
    assert_match 'console.log("app/views/layouts/application.js");', response.body
  end

  test 'stylesheet not found' do
    get '/notfound.css'
    assert_response :missing
  end

  test 'javascript not found' do
    get '/notfound.js'
    assert_response :missing
  end
end
