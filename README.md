# Froxy - Fast Frontend Tooling for Rails

At its most basic, Froxy simply serves as a static delivery machanism for JS and CSS content in your
Rails app. It allows you to serve files from anywhere in your /app directory.

## CSS

CSS requested directly will return a plain stylesheet - as you would expect. But CSS that is
imported from JS will return inject the stylesheet into a `link` tag.

## Images/Fonts, etc.

When called directly, images are served directly - avoiding a call to esbuild. But when an image is
imported from JS or used in a `url()` in CSS, the URL path is returned.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'froxy'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install froxy

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joelmoss/froxy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/joelmoss/froxy/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Froxy project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/joelmoss/froxy/blob/master/CODE_OF_CONDUCT.md).
