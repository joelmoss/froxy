# frozen_string_literal: true

require 'test_helper'

class PostcssBuilderTest < ActionDispatch::IntegrationTest
  test 'stylesheet' do
    get '/app/views/layouts/application.css'

    assert_equal 'text/css', response.headers['Content-Type']
    assert_equal %(
      body {
        color: red;
      }
    ).squish, response.body.squish
  end

  test 'javascript with node_modules CSS import' do
    get '/lib/with_node_modules_css_import.js'

    assert_equal 'application/javascript', response.headers['Content-Type']
    assert_match %(loadStyle_default("/node_modules/react-day-picker/lib/style.css");),
                 response.body
  end

  test 'javascript with CSS module import' do
    get '/lib/some.css',
        headers: { Referer: 'http://www.example.com/lib/with_css_module_import.js' }

    assert_equal 'application/javascript', response.headers['Content-Type']
    assert_matches_snapshot response.body
  end
end
