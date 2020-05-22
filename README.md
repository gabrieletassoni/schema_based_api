# Schema Based Api
I've always been interested in effortless, no-fuss, conventions' based development, DRYness, and pragmatic programming, I've always thought that at this point of the technology evolution, we need not to configure too much to have our software run, having the software adapt to data layers and from there building up APIs, visualizations, etc. in an automatic way. This is a first step to have a schema driven API or better model drive, based on the underlining database, the data it has to serve and some sane dafults, or conventions. This effort also gives, thanks to meta programming, an insight on the actual schema, via the info API, the translations available and the DSL which can change the way the data is presented, leading to a strong base for automatica built of UIs consuming the API (react, vue, angular based PWAs, maybe! ;-) ).

Doing this means also narrowing a bit the scope of the tools, taking decisions, at least for the first implementations and versions of this engine, so, this works well if the data is relational, this is a prerequisite (postgres, mysql, mssql, etc.).

# Goal

To have a comprehensive and meaningful API right out of the box by just creating migrations in your rails app or engine.

# v2?

Yes, this is the second version of such an effort and you can note it from the api calls, which are all under the ```/api/v2``` namespace the [/api/v1](https://github.com/gabrieletassoni/thecore_api) one, was were it all started, many ideas are ported from there, such as the generation of the automatic model based crud actions, as well as custom actions definitions and all the things that make also this gem useful for my daily job were already in place, but it was too coupled with [thecore](https://github.com/gabrieletassoni/thecore)'s [rails_admin](https://github.com/sferik/rails_admin) UI, making it impossible to create a complete UI-less, API only application, out of the box and directly based of the DB schema, with all the bells and whistles I needed (mainly self adapting, data and schema driven API functionalities).
So it all began again, making a better thecore_api gem into this model_driven_api gem, more polished, more functional and self contained.

# Standards Used

* [JWT](https://github.com/jwt/ruby-jwt) for authentication.
* [CanCanCan](https://github.com/CanCanCommunity/cancancan) for authorization.
* [Ransack](https://github.com/activerecord-hackery/ransack) query engine for complex searches going beyond CRUD's listing scope.
* Catch all routing rule to automatically add basic crud operations to any AR model in the app.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'model_driven_api'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install model_driven_api
```

Then run the migrations:
```bash
$ rails db:migrate
```

This will setup a User model, Role model and the HABTM table between the two.

Then, if you fire up your ```rails server``` you can already get a jwt and perform different operations.
The default admin user created during the migration step has a randomly generated password you can find in a .passwords file in the root of your project, that's the initial password, in production you can replace that one, but for testing it proved handy to have it promptly available.

## Consuming the API

### Getting the Token

The first thing that must be done by the client is to get a Token using the credentials:

```bash
POST http://localhost:3000/api/v2/authenticate
```

with a POST body like the one below:

```json
{
	"auth": {
		"email": "<REPLACE>",
		"password": "<REPLACE>"
	}
}
```

This action will return in the header a *Token* you can use for the following requests.
Bear in mind that the *Token* will expire within 15 minutes and that at each succesful request a new token is returned using the same *Token* header, so, at each interaction between client server, just making an authenticated and succesful request, will give you back a way of continuing to make authenticated requests without the extra overhead of an authentication for each one and without having to keep long expiry times for the *Token*.

### Info API

The info API **api/v2/info/** can be used to retrieve general information about the REST API:

#### Version

By issuing a GET on this api, you will get a response containing the version of the model_driven_api. 
This is a request which doesn't require authentication, it could be used as a checkpoint for consuming the resources exposed by this engine.

```bash
GET http://localhost:3000/api/v2/info/version
```

Would produce a response body like this one:

```json
{
  "version": "2.1.14"
}
```

#### Roles

**Authenticated Request** by issuing a GET request to */api/v2/info/roles*:

```bash
GET http://localhost:3000/api/v2/info/roles
```

Something like this can be retrieved:

```json
[
  {
    "id": 1,
    "name": "role-1586521657646",
    "created_at": "2020-04-10T12:27:38.061Z",
    "updated_at": "2020-04-10T12:27:38.061Z",
    "lock_version": 0
  },
  {
    "id": 2,
    "name": "role-1586522353509",
    "created_at": "2020-04-10T12:39:14.276Z",
    "updated_at": "2020-04-10T12:39:14.276Z",
    "lock_version": 0
  }
]
```

#### Schema

**Authenticated Request** This action will send back the *authorized* models accessible by the current user at least for the [:read ability](https://github.com/ryanb/cancan/wiki/checking-abilities). The list will also show the field types of the model and the associations.

By issuing this GET request:

```bash
GET http://localhost:3000/api/v2/info/roles
```

You will get something like:

```json
{
  "users": {
    "id": "integer",
    "email": "string",
    "encrypted_password": "string",
    "admin": "boolean",
    "lock_version": "integer",
    "associations": {
      "has_many": [
        "role_users",
        "roles"
      ],
      "belongs_to": []
    },
    "methods": null
  },
  "role_users": {
    "id": "integer",
    "created_at": "datetime",
    "updated_at": "datetime",
    "associations": {
      "has_many": [],
      "belongs_to": [
        "user",
        "role"
      ]
    },
    "methods": null
  },
  "roles": {
    "id": "integer",
    "name": "string",
    "created_at": "datetime",
    "updated_at": "datetime",
    "lock_version": "integer",
    "associations": {
      "has_many": [
        "role_users",
        "users"
      ],
      "belongs_to": []
    },
    "methods": null
  }
}
```

The *methods* key will list the **custom actions** that can be used in addition to normal CRUD operations, these can be bulk actions and anything that can serve a purpose, usually to simplify the interaction between client and server (i.e. getting in one request the result of a complex computations which usually would be sorted out using more requests). Later on this topic.

## Testing

If you want to manually test the API using [Insomnia](https://insomnia.rest/) you can find the chained request in Insomnia v4 json format inside the **test/insomnia** folder.
In the next few days, I'll publish also the rspec tests.

## TODO

* Integrate a settings gem
* Add DSL for users and roles

## References
THanks to all these people for ideas:

* [Billy Cheng](https://medium.com/@billy.sf.cheng/a-rails-6-application-part-1-api-1ee5ccf7ed01) For a way to have a nice and clean implementation of the JWT on top of Devise.
* [Daniel](https://medium.com/@tdaniel/passing-refreshed-jwts-from-rails-api-using-headers-859f1cfe88e9) For a smart way to manage token expiration.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
