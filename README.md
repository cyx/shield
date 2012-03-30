# Shield

Shield

_n. A solid piece of metal code used to protect your application._

## Why another authentication library?

1. Because most of the other libraries are too huge.
2. Extending other libraries is a pain.
3. Writing code is fun :-)

## What shield is

1. Simple (~ 110 lines of Ruby code)
2. Doesn't get in the way
3. Treats you like a grown up

## What shield is not

- is _not_ a ready-made end-to-end authentication solution.
- is _not_ biased towards any kind of ORM.

## Understanding Shield in 15 minutes

### Shield::Model

`Shield::Model` is a very basic protocol for doing authentication
against your model. It doesn't assume a lot, apart from the following:

1. You will implement `User.fetch` which receives the login string.
2. You have an attribute `crypted_password` which is able to store
   up to __192__ characters.

And that's it.

In order to implement the model protocol, you start by
including `Shield::Model`.

```ruby
class User < Struct.new(:email, :crypted_password)
  include Shield::Model

  def self.fetch(email)
    user = new(email)
    user.password = "pass1234"

    return user
  end
end
```

By including `Shield::Model`, you get all the general methods needed
in order to do authentication.

1. You get `User.authenticate` which receives the login string and
   password as the two parameters.
2. You get `User#password=` which automatically converts the clear text
   password into a hashed form and assigns it into `#crypted_password`.

```ruby
u = User.new("foo@bar.com")

# A password accessor has been added which manages `crypted_password`.
u.password = "pass1234"

Shield::Password.check("pass1234", u.crypted_password)
# => true

# Since we've hard coded all passwords to pass1234
# we're able to authenticate properly.
nil == User.authenticate("foo@bar.com", "pass1234")
# => false

# If we try a different password on the other hand,
# we get `nil`.
nil == User.authenicate("foo@bar.com", "wrong")
# => true
```

Shield includes tests for [ohm][ohm] and [sequel][sequel] and makes sure
that each release works with the latest respective versions.

Take a look at [test/ohm.rb][ohm-test] and [test/sequel.rb][sequel-test]
to learn more.

### Logging in with an email and username?

If your requirements dictate that you need to be able to support logging
in using either username or email, then you can simply extend `User.fetch`
a bit by doing:

```ruby
# in Sequel
class User < Sequel::Model
  def self.fetch(identifier)
    filter(email: identifier).first || filter(username: identifier).first
  end
end

# in Ohm
class User < Ohm::Model
  attribute :email
  attribute :username

  unique :email
  unique :username

  def self.fetch(identifier)
    with(:email, identifier) || with(:username, identifier)
  end
end
```

If you want to allow case-insensitive logins for some reason, you can
simply normalize the values to a `downcase`d version.

[ohm]: http://ohm.keyvalue.org
[sequel]: http://sequel.rubyforge.org

[ohm-test]: https://github.com/cyx/shield/blob/master/test/ohm.rb
[sequel-test]: https://github.com/cyx/shield/blob/master/test/sequel.rb

## Getting started

The fastest way to get started is by cloning the sample cuba-app
located [here][cuba-app].

[cuba-app]: http://github.com/citrusbyte/cuba-app
