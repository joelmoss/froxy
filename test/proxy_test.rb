# frozen_string_literal: true

require 'test_helper'

class ProxyTest < ActionDispatch::IntegrationTest
  test 'side loaded stylesheet' do
    get '/app/views/layouts/application.css'

    assert_equal 'text/css', response.headers['Content-Type']
    assert_match "body {\n  color: red;\n}\n", response.body
  end

  test 'side loaded javascript' do
    get '/app/views/layouts/application.js'

    assert_equal 'application/javascript', response.headers['Content-Type']
    assert_match 'console.log("app/views/layouts/application.js");', response.body
  end
end
