require 'test_helper'

class ProxyTest < ActionDispatch::IntegrationTest
  test 'side loaded stylesheet' do
    get '/froxy/app/views/layouts/application.css'

    assert_match "body {\n  color: red;\n}\n", response.body
  end
end
