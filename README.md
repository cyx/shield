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
simply normalize the values to their lowercase form.

[ohm]: http://ohm.keyvalue.org
[sequel]: http://sequel.rubyforge.org

[ohm-test]: https://github.com/cyx/shield/blob/master/test/ohm.rb
[sequel-test]: https://github.com/cyx/shield/blob/master/test/sequel.rb

### Shield::Helpers

As the name suggests, `Shield::Helpers` is out there to aid you a bit,
but this time it aids you in the context of your Rack application.

`Shield::Helpers` assumes only the following:

1. You have included in your application a Session handler,
   (e.g. Rack::Session::Cookie)
2. You have an `env` method which returns the environment hash as
   was passed in Rack.

**Note:** As of this writing, Sinatra, Cuba & Rails adhere to having an `env`
method in the handler / controller context. Shield also ships with tests for
both Cuba and Sinatra.

```ruby
require "sinatra"

# Satisifies assumption number 1 above.
use Rack::Session::Cookie

# Mixes `Shield::Helpers` into your routes context.
helpers Shield::Helpers

get "/private" do
  error(401) unless authenticated(User)

  "Private"
end

get "/login" do
  erb :login
end

post "/login" do
  if login(User, params[:login], params[:password], params[:remember_me])
    redirect(params[:return] || "/")
  else
    redirect "/login"
  end
end

get "/logout" do
  logout(User)
  redirect "/"
end

__END__

@@ login
<h1>Login</h1>

<form action='/login' method='post'>
<input type='text' name='login' placeholder='Email'>
<input type='password' name='password' placeholder='Password'>
<input type='submit' name='proceed' value='Login'>
```

**Note for the reader**: The redirect to `params[:return]` in the example
is vulnerable to URL hijacking. You can whitelist redirectable urls, or
simply make sure the URL matches the pattern `/\A[\/a-z0-9\-]+\z/i`.

### Shield::Middleware

If you have a keen eye you might have noticed that instead of redirecting
away to the login URL in the example above, we instead chose to do a
`401 Unauthorized`. In strict HTTP Status code terms, this is the proper
approach. The redirection is simply the user experience pattern that has
emerged in web applications.

But don't despair! If you want to do redirects simply add
`Shield::Middleware` to your middleware stack like so:

```ruby
# taken from example above
use Shield::Middleware, "/login"
use Rack::Session::Cookie

# rest of code follows here
# ...
```

Now when your application responds with a `401`, `Shield::Middleware`
will be responsible for doing the redirect to `/login`.

If you try and do a `curl --head http://localhost:4567/private` with
`Shield::Middleware`, you'll get a response similar to the following:

```
HTTP/1.1 302 Found
Location: http://localhost:4567/login?return=%2Fprivate
Content-Type: text/html
```

Notice that it specifies `/private` as the return URL.

## Jump starting your way.

For people interested in using Cuba, Ohm, Shield and Bootstrap we've
created a starting point that includes **Login**, **Signup** and
**Forgot Password** functionality.

Head on over to the [cuba-app][cuba-app] repository if you want
to know more.

[cuba-app]: http://github.com/citrusbyte/cuba-app
