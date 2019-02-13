# Gofundme

THE #1 Ruby library to scrape GoFundMe.com donation campaigns (called Projects by this library). GoFundMe does not have a publicly available API to query about donation lists, so this library scrapes information from GoFundMe's own mvc.php API using rest_client. This library is liable to break if GFM changes their API consumption endpoints

This Library is not associated to GoFundMe, Inc. in any way, shape, or form.

This description lifted from [the excellent Node.js library by 0nix](https://github.com/0nix/gofundme). Although the code is completely unrelated.

For a larger scale spider with Proxy support check this [Ruby and Javascript scraper with MongoDB back-end](https://github.com/asanteb/gofundme-scraper)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gofundme'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gofundme

## Usage

```ruby
require 'gofundme'

# Fetch an index for a search query
query = "transgender"
search = Gofundme::Search.new(query)
# => #<Gofundme::Search:0x000055c96dbe90d8 @results=1000, @pages=112, @query="transgender">
# Total pages for the query are in
puts "Total pages: #{search.pages}"
page_number = 1
# This returns an array of links
links = search.fetch_results(page_number)
# => ["https://www.gofundme.c...", ...]
links.length
# => 9
# Get the full project details
url = links.last
project = Gofundme::Project.scrape(url)
# => #<Gofundme::Project:0x000055c96dbcf2c8 @updates=[[1, ...
project.to_hash.keys
# => [:key, :category, :completed, :title, :name, :profile, :location, :image, :youtube, :vimeo, :images, :shares, :amount, :goal, :pounds, :euros, :goal_pounds, :goal_euros, :backers, :time, :trending, :english, :story_text, :story_html, :link_count, :updates_count, :created_at, :fb_shares, :updates]
```

## The More You Know

A Word about Gofundme::GOOD_CITIZEN_DELAY. The robots.txt on GoFundMe is very permissible. Many companies will go out of their way to prevent people from scraping their site. So far GoFundMe is making things very easy to access. They do NOT have to do this. There are a hundred ways they could make this harder and nobody wants that. Keeping this information accessible helps both GoFundMe and their customers by allowing research into how campaigns can be more successful. Please keep this number in place. Based on experimentation you will be banned by their site if you go lower than 5 seconds delay. It can be set like:

Gofundme::GOOD_CITIZEN_DELAY = 5

And yes you will get a redefined constant error.

You can set Gofundme::DEBUG to true and get some messages on STDERR.

One of three header elements will be set on a given Gofundme::Project profile page.

1. :image -> if the user only sets a image as the project primary image
2. :youtube -> if the user has set a YouTube video in the place of the primary image
3. :vimeo -> if the user has set a Vimeo video in place of the primary image

If the project is in Euros or Pounds the values will automatically be converted into USD and set in amount and goal. This leaves the original amount raised in :pounds or :euros and the goals in :goal_pounds or :goal_euros. The conversion is based on.

1. Gofundme::EURO_EXCHANGE_RATE = 1.13
2. Gofundme::POUND_EXCHANGE_RATE = 1.31

These are in lib/gofundme.rb.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jjeffus/gofundme. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Gofundme project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/jjeffus/gofundme/blob/master/CODE_OF_CONDUCT.md).
