# Schema Based Api
I've always been interested in effortless, no-fuss, conventions' based development, DRYness, and pragmatic programming, I've always thought that at this point of the technology evolution, we need not to configure too much to have our software run, having the software adapt to data layers and from there building up APIs, visualizations, etc. in an automatic way. This is a first step to have a schema driven API or better model drive, based on the underlining database, the data it has to serve and some sane dafults, or conventions. This effort also gives, thanks to meta programming, an insight on the actual schema, via the info API, the translations available and the DSL which can change the way the data is presented, leading to a strong base for automatica built of UIs consuming the API (react, vue, angular based PWAs, maybe! ;-) ).

Doing this means also narrowing a bit the scope of the tools, taking decisions, at least for the first implementations and versions of this engine, so, this works well if the data is relational, this is a prerequisite (postgres, mysql, mssql, etc.).

# Goal

To have a comprehensive and meaningful API right out of the box by just creating migrations in your rails app or engine.

# v2?

Yes, this is the second version of such an effort, the [v1](https://github.com/gabrieletassoni/thecore_api) was were it all started, many ideas are ported from there, such as the generation of the automatic model based crud actions, as well as custom actions definitions and all the things that make also this gem useful for my daily job were already in place, but it was too coupled with [thecore](https://github.com/gabrieletassoni/thecore)'s [rails_admin](https://github.com/sferik/rails_admin) UI, making it impossible to create a complete UI-less, API only application, out of the box and directly based of the DB schema, with all the bells and whistles I needed (mainly self adapting, data and schema driven API functionalities).
So it all began again, making a better thecore_api gem into this schema_based_api gem, more polished, more functional and self contained.

# Standards Used

* [JWT](https://github.com/jwt/ruby-jwt) for authentication.
* [CanCanCan](https://github.com/CanCanCommunity/cancancan) for authorization.
* [Active Hash Relation](https://github.com/kollegorna/active_hash_relation) for DSL.
* [Ransack](https://github.com/activerecord-hackery/ransack) query engine for complex searches going beyond CRUD's listing scope.
* Catch all routing rule to add basic crud operations to any AR model in the app.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'schema_based_api'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install schema_based_api
```

Then run the migrations:
```bash
$ rails db:migrate
```

This will setup a User model, Role model and the HABTM table between the two.

Then, if you fire up your ```rails server``` you can already get a jwt and perform different operations.
The default admin user created during the migration step has a randomly generated password you can find in a .passwords file in the root of your project, that's the initial password, in production you can replace that one, but for testing it proved handy to have it promptly available.

## Testing

If you want to manually test the API using [Insomnia](https://insomnia.rest/) I will publish in the repository the export for the chained requests I'm using.
In the next few days, I'll publish also the rspec tests.

## References
THanks to all these people for ideas:

* [Billy Cheng](https://medium.com/@billy.sf.cheng/a-rails-6-application-part-1-api-1ee5ccf7ed01) For a way to have a nice and clean implementation of the JWT on top of Devise.
* [Daniel](https://medium.com/@tdaniel/passing-refreshed-jwts-from-rails-api-using-headers-859f1cfe88e9) For a smart way to manage token expiration.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
