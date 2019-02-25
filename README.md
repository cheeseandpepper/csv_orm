# CsvOrm

Sometimes you get a csv file and are asked to do some basic query type stuff with it. If you're like me and hate excel, and would rather pretend that this is in a db and you're using Activerecord as your ORM, then this gem will be of use to you.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'csv_orm'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install csv_orm

## Usage

```ruby
  my_csv = CsvOrm::Ingestor.new('path/to/csv.csv')
  my_data = CsvOrm::Query.new(my_csv)
```

Now you can do activerecord like queries on the dataset. Currently it supports 3 methods:

```ruby
#where({key: 'value', other_key: 'other_value'}) (all conditions must be met)
#where_any({key: 'value', other_key: 'other_value'}) (like an 'or' condition)
#aggregate(:field1, :field2) (count unique values for each field)
```

```ruby
  # show users who are admin and named 'Mike'
  my_data.where({admin: true, first_name: 'Mike'})
  
  # show users who have admin access or have last name N-Z
  my_data.where_any({admin: true, last_name: /^[n-zN-Z].*/})

  # give me a break down of orders by their delivery status for users named 'Mike'
  my_data.where({first_name: 'Mike'}).aggregate(:delivery_status, :admin)
  #=> {
    delivery_status: {placed: 10, processing: 22, shipped: 43, delivered: 25},
    admin: { true: 45, false: 55 }
  }
```

Maybe more will come...

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Mike Lerner/csv_orm.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

