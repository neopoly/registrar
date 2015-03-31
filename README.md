[github]: https://github.com/JanOwiesniak/registrar
[doc]: http://rubydoc.info/github/JanOwiesniak/registrar/master/file/README.md
[gem]: https://rubygems.org/gems/registrar
[gem-badge]: https://img.shields.io/gem/v/registrar.svg
[rack-playground]: https://github.com/JanOwiesniak/rack-playground/blob/master/lib/app_builder.rb

# Registrar: Standardized Multi-Provider Registration

[![Gem Version][gem-badge]][gem]

[Gem][gem] |
[Source][github] |
[Documentation][doc]

## Introduction

Registrar standardizes the authentication process through [Rack Middleware](https://github.com/rack/rack#available-middleware) and works well with common authentication mechanisms like [OmniAuth](https://github.com/intridea/omniauth).

## Description

You can think of Registrar as a thin wrapper around your sign up / sign in process.

Registrar already has [build in support](https://github.com/JanOwiesniak/registrar/blob/master/lib/registrar/auth_builder/omni_auth.rb) for the [OmniAuth Auth Hash Schema](https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema).

If you want to use a different authentication mechanisms feel free to implement your own [AuthBuilder](https://github.com/JanOwiesniak/registrar/wiki/AuthBuilder).

## Getting Started

Let us start with a short example.

I'm using an [fork](https://github.com/JanOwiesniak/omniauth-facebook-access-token) (see here why i use a [fork](https://github.com/JanOwiesniak/omniauth-facebook-access-token/commit/6df0d75d5b9a3c866eea63d2495da0376091cbbe)) of the [omniauth-facebook-access-token](https://github.com/JanOwiesniak/omniauth-facebook-access-token) OmniAuth strategy to authenticate my user.

Add `registrar` and the authenticaton mechanism you want to use to your `Gemfile`

```ruby
gem 'registrar'
gem 'omniauth-facebook-access-token' # we are just using one OmniAuth strategy here
```

Add the authentication mechanism of your choice

```ruby
require 'omniauth-facebook-access-token'

app = Rack::Builder.app do
  # Store authenticated user in env['omniauth.auth']
  use OmniAuth::Builder do
    provider omniauth-facebook-access-token
  end

  run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['OK']] }
end

run app
```

Add a appropriate AuthBuilder to your Middleware Stack to transform the previous authentication result into registrar schema.

```ruby
require 'registrar'
require 'omniauth-facebook-access-token'

app = Rack::Builder.app do
  # Store authenticated user in env['omniauth.auth']
  use OmniAuth::Builder do
    provider omniauth-facebook-access-token
  end

  # Transform the OmniAuth Schema env['omniauth.auth'] into the Registrar Schema env['registrar.auth']
  use Registrar::AuthBuilder::OmniAuth

  run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['OK']] }
end

run app
```

Go to the [Facebook Graph API Explorer](https://developers.facebook.com/tools/explorer/), generate a access token and copy it to your clipboard.

Start the application, visit localhost:port/auth/facebook_access_token and paste the access token from your clipboard. Click the submit button.

If you inspect your env you should find the schema OmniAuth builds for you `env['omniauth.auth']`

```bash
!ruby/hash:OmniAuth::AuthHash
  provider: facebook
  uid: '100000100277322'
  info: !ruby/hash:OmniAuth::AuthHash::InfoHash
    email: janowiesniak@gmx.de
    name: Jan Ow
    first_name: Jan
    last_name: Ow
    image: http://graph.facebook.com/100000100277322/picture
    urls: !ruby/hash:OmniAuth::AuthHash
      Facebook: http://www.facebook.com/100000100277322
    location: Bochum, Germany
    verified: true
  credentials: !ruby/hash:OmniAuth::AuthHash
    token: CAACEdEose0cBABZBEayxJNmeCRdvrwT6RbiEbtYUyAZCY24E5xxCoPQJ0oCVR8XFsUEtTpnMjwrRMwvjliQe2xDRM2c76ONriaNQaMwuAKH1YjQki9lK8evIkN18TqPopB1blbeRuOIkes2l4JQ3Ga7HL9vHXHqhAjcbuZCHKhtOJMulZAN1wfWMlOxF7bBZCW0TdzJz654CW7ErAsIPj
    expires: false
  extra: !ruby/hash:OmniAuth::AuthHash
    raw_info: !ruby/hash:OmniAuth::AuthHash
      id: '100000100277322'
      email: janowiesniak@gmx.de
      first_name: Jan
      gender: male
      last_name: Ow
      link: http://www.facebook.com/100000100277322
      location: !ruby/hash:OmniAuth::AuthHash
        id: '106544749381682'
        name: Bochum, Germany
      locale: en_US
      name: Jan Ow
      timezone: 1
      updated_time: '2015-01-10T11:52:30+0000'
      verified: true
```

Besides that you should also find the schema registrar, in this case Registrar::AuthBuilder::OmniAuth, builds for you `env['registrar.auth']`

```bash
  provider:
    name: facebook
    uid: '100000100277322'
    access_token: CAACEdEose0cBABZBEayxJNmeCRdvrwT6RbiEbtYUyAZCY24E5xxCoPQJ0oCVR8XFsUEtTpnMjwrRMwvjliQe2xDRM2c76ONriaNQaMwuAKH1YjQki9lK8evIkN18TqPopB1blbeRuOIkes2l4JQ3Ga7HL9vHXHqhAjcbuZCHKhtOJMulZAN1wfWMlOxF7bBZCW0TdzJz654CW7ErAsIPj
  profile:
    name: Jan Ow
    email: janowiesniak@gmx.de
    location: Bochum, Germany
    image: http://graph.facebook.com/100000100277322/picture
  trace:
    ip: 127.0.0.1
    user_agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko)
      Chrome/40.0.2214.91 Safari/537.36
    timestamp: '1427800292'
```

Nothing special for now. The AuthBuilder just transform the Hash into a different structure for now.

In the general case you want to do something with the authenticated user (e.g. sign up or sign in), this is where the profile builder come into play.

Open up you Middewarestack again.

```ruby
require 'registrar'
require 'omniauth-facebook-access-token'

app = Rack::Builder.app do
  # Store authenticated user in env['omniauth.auth']
  use OmniAuth::Builder do
    provider omniauth-facebook-access-token
  end

  # Transform the OmniAuth Schema env['omniauth.auth'] into the Registrar Schema env['registrar.auth']
  use Registrar::AuthBuilder::OmniAuth

  # Handle Registrar Schema env['registrar.auth'] and store processed result into env['registrar.profile']
  use Registrar::ProfileBuilder, Proc.new {|schema| #find_or_create_profile_in_persistence }

  run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['OK']] }
end

run app
```

In this case i passed the Registrar Schema to a application related service called ProfileRegister which returned me a application specific Profile.

This profile is stored in `env['registrar.profile']`

```bash
!ruby/object:ProfileRegister::Services::ProfileBoundary::Profile
  o: 
  t:
    :profile_uid: '1'
    :provider: facebook
    :access_token: a39147c2f57f3797f58a
    :external_uid: '100000100277322'
    :display_name: Jan Ow
    :country_code: 
    :avatar: http://graph.facebook.com/100000100277322/picture
    :email: janowiesniak@gmx.de
    :terms_accepted: false
    :registration_platform: 
    :gender: 
    :language: 
    :birthday: 
    :fresh: true
    :last_login: &1 !ruby/object:ProfileRegister::Services::ProfileBoundary::LastLogin
      o: 
      t:
        :time: 2015-03-31 11:11:32.000000000 Z
        :address: 127.0.0.1
        :user_agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like
          Gecko) Chrome/40.0.2214.91 Safari/537.36
```

If your application supports the concept of a session your could store env['registrar.profile'] in your session to log the user in.

```ruby
if env['registrar.profile']
  @session['current_profile'] = env['registrar.profile']
end
```

If you decide to do this you could also add some helper methods.

```ruby
def current_profile
  @session['current_profile']
end

def logged_in?
  !!current_profile
end

def logged_out?
  !logged_in?
end
```

If you are using `Rails` you should probably check out [registrar-rails](https://github.com/JanOwiesniak/registrar-rails) which gives you a small interface to configure your middleware as well as some helper methods like i suggest above.

## Contributing

1. Fork it ( https://github.com/JanOwiesniak/registrar/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
