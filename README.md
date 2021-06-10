# FancyCount

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/fancy_count`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fancy_count'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install fancy_count

## Usage

Fancy count is nothing more than a simple counter library with some functionality baked in to manage those counters
in Redis and manage counter caches (in Rails).

Example usage in IRB

```ruby
counter = FancyCount::Counter.new('my-counter')
counter.increment
counter.value # => 1
counter.decrement # => 0
```

Example usage in an ActiveRecord Model

```ruby
class Company < ApplicationRecord
  include FancyCount::HasCountable

  fancy_counter :employees
end

company = Company.new
company.fancy_employee_count # => 0
company.fancy_employee_counter.increment
company.fancy_employee_count # => 1
```

Example Counter Cache

```ruby
class Company < ApplicationRecord
  include FancyCount::HasCountable

  fancy_counter :employees
end

class Employee < ApplicationRecord
  include FancyCount::CounterCacheable

  belongs_to :company

  fancy_counter_cache :employees, on: :company
end

company = Company.first
company.fancy_employee_count # => 0
company.employees.create(name: "bob marley")
company.fancy_employee_count # => 1
company.employees.destroy_all
company.fancy_employee_count # => 0
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

### Releasing a new version

* install gem-release https://github.com/svenfuchs/gem-release
* run `gem bump --version patch` if patching (otherwise switch "patch" out for "minor" or "major")
* run `gem tag 1.x.x` replacing the "x" characters with appropriate values
* run `git push --tags origin` to push the tags up to Github
* Finally, run `gem release` which pushes the gem up to whatever repository (ex: Rubygems)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/CompanyCam/fancy-count. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/CompanyCam/fancy-count/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FancyCount project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/CompanyCam/fancy-count/blob/master/CODE_OF_CONDUCT.md).
