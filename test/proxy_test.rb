# frozen_string_literal: true

require 'test_helper'

class ProxyTest < ActionDispatch::IntegrationTest
  test 'stylesheet' do
    get '/app/views/layouts/application.css'

    assert_equal 'text/css', response.headers['Content-Type']
    assert_equal %(
      /* app/views/layouts/application.css */
      body {
        color: red;
      }
    ).squish, response.body.squish
  end

  test 'stylesheet with @import' do
    get '/lib/with_import.css'

    assert_equal 'text/css', response.headers['Content-Type']
    assert_equal %(
      /* lib/reset.css */
      body {
        font-size: 16px;
      }
      /* app/views/layouts/application.css */
      body {
        color: red;
      }
      /* lib/with_import.css */
      body {
        color: red;
      }
    ).squish, response.body.squish
  end

  test 'stylesheet with url() image' do
    get '/lib/with_url_image.css'

    assert_equal 'text/css', response.headers['Content-Type']
    assert_equal 'body { background: url(/lib/avatar.png);'.squish, response.body.squish
  end

  test 'javascript' do
    get '/app/views/layouts/application.js'

    assert_equal 'application/javascript', response.headers['Content-Type']
    assert_equal %(
      // app/views/layouts/application.js
      console.log("app/views/layouts/application.js");
    ).squish, response.body.squish
  end

  test 'javascript with import' do
    get '/lib/with_import.js'

    assert_equal 'application/javascript', response.headers['Content-Type']
    assert_equal %(
      // app/views/layouts/application.js
      console.log("app/views/layouts/application.js");

      // lib/common.js
      console.log("lib/common.js");

      // lib/with_import.js
      console.log("/lib/with_import.js");
    ).squish, response.body.squish
  end

  test 'javascript with css import' do
    get '/lib/with_css_import.js'

    assert_equal 'application/javascript', response.headers['Content-Type']
    assert_match %(
      // cssFromJs:/Users/joelmoss/dev/froxy/test/internal/lib/reset.css
      loadStyle_default("/lib/reset.css");

      // cssFromJs:/Users/joelmoss/dev/froxy/test/internal/lib/some.css
      loadStyle_default("/lib/some.css");

      // lib/with_css_import.js
      console.log("/lib/with_css_import.js");
    ).squish, response.body.squish
  end

  test 'javascript with image import' do
    get '/lib/with_image_import.js'

    assert_equal 'application/javascript', response.headers['Content-Type']
    assert_equal %(
      // lib/avatar.png
      var avatar_default = "/lib/avatar.png";

      // lib/images/man.jpg
      var man_default = "/lib/images/man.jpg";

      // lib/with_image_import.js
      console.log(avatar_default, man_default);
      console.log("/lib/with_image_import.js");
    ).squish, response.body.squish
  end

  test 'image' do
    get '/lib/avatar.png'

    assert_equal 'image/png', response.headers['Content-Type']
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
