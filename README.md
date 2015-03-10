[github]: https://github.com/JanOwiesniak/registrar
[doc]: http://rubydoc.info/github/JanOwiesniak/registrar/master/file/README.md
[gem]: https://rubygems.org/gems/registrar
[gem-badge]: https://img.shields.io/gem/v/registrar.svg
[rack-playground]: https://github.com/JanOwiesniak/rack-playground/blob/master/lib/app_builder.rb

# Registrar

[![Gem Version][gem-badge]][gem]

[Gem][gem] |
[Source][github] |
[Documentation][doc]

# Description

Registrar standardizes Authentication Responses through Rack Middleware and works well with common authentication mechanisms like OmniAuth.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'registrar'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install registrar

## Usage

Click [here][rack-playground] to see how to use the different components.

## Short summary of the components

### Gatekeeper

It normalizes the interface.

## Adapter

It normalizes the response.

## ProfileFactory

It passes the normalized response to a profile factory and stores a hash version
of the returned object in the env.

## Contributing

1. Fork it ( https://github.com/JanOwiesniak/registrar/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
