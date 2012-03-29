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

Take a look at test/ohm.rb and test/sequel.rb to learn more.

## Getting started

The fastest way to get started is by cloning the sample cuba-app
located [here][cuba-app].

[cuba-app]: http://github.com/citrusbyte/cuba-app
