require 'test_helper'

class SideLoadTest < ActionDispatch::IntegrationTest
  test 'stylesheet' do
    get '/'

    assert_match '<link rel="stylesheet" media="screen" href="/froxy/app/views/layouts/application.css" />',
                 response.body
  end
end
