# remotelock-sdk
[![Test](https://github.com/morganism/remotelock-sdk/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/morganism/remotelock-sdk/actions/workflows/test.yml) [![Release](https://github.com/morganism/remotelock-sdk/actions/workflows/release.yml/badge.svg?branch=master)](https://github.com/morganism/remotelock-sdk/actions/workflows/release.yml)  [![Gem Version](https://badge.fury.io/rb/remotelock-sdk.svg)](https://badge.fury.io/rb/remotelock-sdk) ![](http://ruby-gem-downloads-badge.herokuapp.com/remotelock-sdk?type=total)

This is a Ruby SDK for v2 of
[Remotelock](https://www.remotelock.com/)'s public API. It aims to be
more lightweight, consistent, simple, and convenient than an
auto-generated SDK.

As well as complete API coverage, `remotelock-sdk` includes methods
which facilitate various common tasks, and provides non-API
features such as credential management, and writing points through a
proxy. It also has methods mimicking the behaviour of useful v1 API
calls which did not make it into v2.

## Prerequisites

- you'll need a physical device. i.e. a keyless doorlock by [RemoteLock](https://remotelock.com/hardware/locks-we-support/) great for AirBnB or your own residence. This system has changed my relationship to keys and how I allow access to my house. Bonmarché !

- and a developer account [RemoteLock Developers](https://developer.remotelock.com/users/sign_in) . Create your OAuth application, recieve your client secret and id and you're good to go.

- ruby ! this is a ruby application

- an understanding of REST, Webhooks, APIs is desirable
  

## Installation

```
$ gem install remotelock-sdk
```

or to build locally,

```
$ gem build remotelock-sdk.gemspec
```

`remotelock-sdk` requires Ruby >= 2.7. All its dependencies are pure
Ruby, right the way down, so a compiler should never be required to
install it.

## Documentation

The code is documented with [YARD](http://yardoc.org/) and
automatically generated documentation is [available on
rubydoc.info](http://www.rubydoc.info/gems/remotelock-sdk/).

## Examples

First, let's list the Remotelock proxies in our account. The `list()`
method will return a `Remotelock::Response` object. This object has
`status` and `response` methods. `status` always yields a structure
containing `result`, `message` and `code` fields which can be
inspected to ensure an API call was processed successfully.
`response` gives you the JSON response from the API, conveniently
processed and turned into a [`Map`](https://github.com/ahoward/map)
object. Map objects can be interrogated in various ways. For
instance `map['items']`, `map[:items]` and `map.items` will all get
you to the same place.

### Standard API Calls

```ruby
# Define our API endpoint. (This is not a valid token!)

CREDS = { endpoint: 'api.remotelock.com',
          token: 'c7a1ff30-0dd8-fa60-e14d-f58f91bafc0e' }

require 'remotelock-sdk/proxy'

# You can pass in a Ruby logger object, and tell the SDK to be
# verbose.

require 'logger'
log = Logger.new(STDOUT)

rl = Remotelock::User.new(CREDS, verbose: true, logger: log)
```

By default (because it's the default behaviour of the API),
all API classes (except `user`) will only return blocks of results
when you ask for a list of objects.


You can set an offset and a limit when you list, but setting the
limit to the magic value `:all` will return all items, without you
having to deal with pagination. When you do that, `offset` is repurposed as
the number of results fetched with each call to the API.

Calling a method with the limit set to `:lazy` returns a lazy
enumerable. Again, `offset` is the chunk size.

```ruby
rl = Remotelock::AccessUser.new(creds.all)

# The first argument is how many object to get with each API call,
# the second gets us a lazy #Enumerable
rl.list(99, :lazy).each { |access_user| puts access_user.show }
# Type: Guest
# Name: Morgan 
# ...
```

## Contributing

Fork it, fix it, send me a PR. Please supply tests, and try to keep
[Rubocop](https://github.com/bbatsov/rubocop) happy.
