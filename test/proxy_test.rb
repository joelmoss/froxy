# frozen_string_literal: true

require 'test_helper'

class ProxyTest < ActionDispatch::IntegrationTest
  test 'stylesheet' do
    get '/app/views/layouts/application.css'

    assert_equal 'text/css', response.headers['Content-Type']
    assert_equal %(
      body {
        color: red;
      }
    ).squish, response.body.squish
  end

  test 'stylesheet with postcss' do
    get '/lib/with_postcss.css'

    assert_equal 'text/css', response.headers['Content-Type']
    assert_equal %(
      html body { color: blue; }
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
    assert_match 'body { background: url(/lib/avatar.png);'.squish, response.body.squish
  end

  test 'javascript' do
    get '/app/views/layouts/application.js'

    assert_equal 'application/javascript', response.headers['Content-Type']
    assert_equal %(
      // app/views/layouts/application.js
      console.log("app/views/layouts/application.js");
    ).squish, response.body.squish
  end

  test 'jsx' do
    get '/app/components/link.jsx'

    assert_equal 'application/javascript', response.headers['Content-Type']
    assert_equal %(
      // app/components/link.jsx
      function link_default() {
        return /* @__PURE__ */ React.createElement("a", {
          href: "https://github.com/joelmoss/froxy"
        }, "I'm a Link!");
      }
      export {
        link_default as default
      };
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

  test 'javascript with node_modules CSS import' do
    get '/lib/with_node_modules_css_import.js'

    assert_equal 'application/javascript', response.headers['Content-Type']
    assert_match %(loadStyle_default("/node_modules/react-day-picker/lib/style.css");),
                 response.body
  end

  test 'javascript with css import' do
    get '/lib/with_css_import.js'

    assert_equal 'application/javascript', response.headers['Content-Type']
    assert_match %(loadStyle_default("/lib/reset.css");), response.body
    assert_match %(loadStyle_default("/lib/reset.css");), response.body
    assert_match %(console.log("/lib/with_css_import.js");), response.body
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

  test 'javascript with node module alias import' do
    get '/lib/with_node_module_alias_import.js'

    assert_equal 'application/javascript', response.headers['Content-Type']
    assert_match %(
      // lib/with_node_module_alias_import.js
      console.log(isArray_default([]));
      console.log("/lib/with_node_module_alias_import.js");
    ).squish, response.body.squish
  end

  test 'javascript with local alias import' do
    get '/lib/with_local_alias_import.js'

    assert_equal 'application/javascript', response.headers['Content-Type']
    assert_match %(
      // lib/time.js
      var time_default = "2pm";

      // lib/with_local_alias_import.js
      console.log(`time = ${time_default}`);
      console.log("/lib/with_local_alias_import.js");
    ).squish, response.body.squish
  end

  # focus
  # test 'javascript with dynamic split import' do
  #   get '/lib/with_dynamic_import.js'

  #   assert_equal 'application/javascript', response.headers['Content-Type']
  #   assert_equal %(
  #     // lib/with_image_import.js
  #     import avatar1 from "/lib/avatar.png";
  #     import avatar2 from "/lib/images/man.jpg";
  #     console.log(avatar1, avatar2);
  #     console.log("/lib/with_image_import.js");
  #   ).squish, response.body.squish
  # end

  test 'image' do
    get '/lib/avatar.png'

    assert_equal 'image/png', response.headers['Content-Type']
  end

  test 'stylesheet not found' do
    assert_raises ActionController::RoutingError do
      get '/notfound.css'
    end
  end

  test 'javascript not found' do
    assert_raises ActionController::RoutingError do
      get '/notfound.js'
    end
  end
end
