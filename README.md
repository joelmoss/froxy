# Froxy - Fast ESModule based Frontend Bundling for Rails

Froxy serves as a delivery machanism for all your frontend assets in Rails applications. It is
designed specifically for Rails applications, and can completely replace Webpacker and the Rails
asset pipeline (Sprockets) by bundling your ESModule based frontend code in real time and on demand.
It does this by proxying all frontend requests to the amazing [esbuild](https://esbuild.github.io).

## ! NOT PRODUCTION READY !

Froxy is currently an experimental library and does not yet have a production or deployment mode.
While you could deploy it and run it in production, it is highly recommended that you do not do
this. This is because almost every asset is bundled and built in real time by request. A future
production mode will likely include pre-built cachable assets.

-- _YOU HAVE BEEN WARNED!_

## Features

- Real-time bundling of JS, JSX and CSS.
- Import CSS and other static assets (images, fonts, etc.)
- Serve assets from anywhere within the Rails root. (eg. `/app/views/layouts/application.css`, or `/lib/utils/time.js`)
- Side loaded JS/CSS for your layouts and views.
- [Tree shaking](https://esbuild.github.io/api/#tree-shaking).

## Roadmap

In no particular order:

- Code Splitting.
- Source Maps.
- Minification.
- Pre-bundling / cached assets.
- Typescript.
- CSS Modules.
- PostCSS support.

## Javascript

Import any JS:

```javascript
import start from '/my/start' // Local absolute path
import start from './start' // Local relative path
import start from 'start' // From node modules
```

All JS is [bundled](https://esbuild.github.io/api/#bundle) by esbuild, which will inline any
imported dependencies into the file itself.

The JS file extension is not required and is assumed.

## CSS

CSS requested directly will return a plain stylesheet - as you would expect. But CSS that is
imported from JS will result in the requested CSS injected into an HTML `link` tag.

```javascript
import '/my/styles.css'
```

## Images/Fonts, etc.

When called directly, images are served directly - avoiding a call to esbuild. But when an image is
imported from JS or used in a `url()` in CSS, the URL path is returned.

Examples (where 'avatar.png' is located in '/app/images', but could be anywhere):

```javascript
// /app/views/home.js
import imgUrl from '../images/avatar.png' // imgUrl == "/app/images/avatar.png"
```

```css
body {
  background-image: url('/app/images/avatar.png');
}
```

## Side Loaded JS/CSS

Froxy also has built in support for automatically side loading JS and CSS with your views and
layouts.

Just create a JS and/or CSS file with the same name as any view or layout, and make sure your
layouts include the `<%= yield :side_loaded_js %>` and `<%= yield :side_loaded_css %>`. Something
like this:

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Hello World</title>
    <%= yield :side_loaded_css %>
  </head>
  <body>
    <%= yield %> <%= yield :side_loaded_js %>
  </body>
</html>
```

On each page request, Froxy will check if your layout and view has a JS/CSS file of the same name,
and include them into your layout HTML.

## Import aliases

Module aliases can be defined in your package.json, supporting local and node modules.

In your package.json:

```json
"froxy": {
  "aliases": {
    "_": "lodash", // a node module
    "myalias": "/absolute/path/to/alias.js", // local path
  }
}
```

Then import:

```javascript
import { map } from '_'
import axios from 'myaxios'
```

## Installation

Froxy requires Rails 6+ and Node.

Add this line to your application's Gemfile:

```ruby
gem 'froxy'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install froxy

## Configuration

There are a few options that you can customise, and they are all defined in your `package.json`. For
example:

```json
"froxy": {
  "target": [],
  "aliases": {
    "_": "lodash"
  }
}
```

### `target`

See esbuild's documentation on [defining targets](https://esbuild.github.io/api/#target).

### `aliases`

See [aliases](#import-aliases)

### `minify`

(default: `true`)

See esbuild's documentation on [minification](https://esbuild.github.io/api/#minify).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joelmoss/froxy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/joelmoss/froxy/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Froxy project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/joelmoss/froxy/blob/master/CODE_OF_CONDUCT.md).
