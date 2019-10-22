# Hatenablog

[![Gem Version](https://badge.fury.io/rb/hatenablog.svg)](https://badge.fury.io/rb/hatenablog) [![Build Status](https://github.com/kymmt90/hatenablog/workflows/build/badge.svg)](https://github.com/kymmt90/hatenablog/actions?workflow=build)
[![Code Climate](https://codeclimate.com/github/kymmt90/hatenablog/badges/gpa.svg)](https://codeclimate.com/github/kymmt90/hatenablog)
[![Test Coverage](https://codeclimate.com/github/kymmt90/hatenablog/badges/coverage.svg)](https://codeclimate.com/github/kymmt90/hatenablog/coverage)

> A library for Hatena Blog AtomPub API

This gem supports following operations through OAuth 1.0a or Basic authentication:

- Get blog feeds, entries and categories
- Post blog entries
- Update blog entries
- Delete blog entries

## Installation

### Install the gem

Add this line to your application's Gemfile:

    gem 'hatenablog'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hatenablog

### Get OAuth credentials

You need to set up OAuth 1.0a keys and tokens before using this gem.

#### 1. Get consumer key and consumer key secret

Access [Hatena application registoration page](http://developer.hatena.ne.jp/) and get your application consumer key.

#### 2. Get your access token and access token secret

Execute this command:

    $ get_access_token <your consumer key> <your consumer secret>
    Visit this website and get the PIN: https://www.hatena.com/oauth/authorize?oauth_token=XXXXXXXXXXXXXXXXXXXX
    Enter the PIN: <your PIN> [Enter]
    Access token: <your access token>
    Access token secret: <your access token secret>

#### 3. [Optional] Set up the YAML configuration file

The default configuration file name is `config.yml`:

```yml
consumer_key: <Hatena application consumer key>
consumer_secret: <Hatena application consumer secret>
access_token: <Hatena application access token>
access_token_secret: <Hatena application access token secret>
user_id: <Hatena user ID>
blog_id: <Hatenablog ID>
```

This file accepts ERB syntax.

```yml
consumer_key: <%= ENV['CONSUMER_KEY'] %>
consumer_secret: <%= ENV['CONSUMER_SECRET'] %>
access_token: <%= ENV['ACCESS_TOKEN'] %>
access_token_secret: <%= ENV['ACCESS_TOKEN_SECRET'] %>
user_id: <%= ENV['USER_ID'] %>
blog_id: <%= ENV['BLOG_ID'] %>
```

`blog_id` means your Hatena Blog domain, like "example-user.hatenablog.com".

You also can set these configurations in your code as described in [the below section](#factories).

### [Optional] Get Basic authentication credentials
If you want to use Basic authentication, visit `http://blog.hatena.ne.jp/#{user_id}/#{blog_id}/config/detail`
and check your API key and set up `config.yml` like the following.

```yml
auth_type: basic
api_key: <%= ENV['API_KEY'] %>
user_id: <%= ENV['USER_ID'] %>
blog_id: <%= ENV['BLOG_ID'] %>
```

## Usage

```ruby
require 'hatenablog'

# Read the configuration from 'config.yml'
Hatenablog::Client.create do |blog|
  # Get each entry's content
  blog.entries.each do |entry|
    puts entry.content
  end

  # Post new entry
  posted_entry = blog.post_entry(
    'Entry Title',
    'This is entry contents', # markdown form
    ['Test', 'Programming']   # categories
  )

  # Update entry
  updated_entry = blog.update_entry(
    posted_entry.id,
    'Revised Entry Title',
    posted_entry.content,
    posted_entry.categories
  )

  # Delete entry
  blog.delete_entry(updated_entry.id)
end
```

## API

### Factories

You can create the client from the configuration file.

```ruby
# Create the client from "./config.yml"
client = Hatenablog::Client.create

# Create the client from the specified configuration
client = Hatenablog::Client.create('../another_config.yml')

Hatenablog::Client.create do |client|
  # Use the client in the block
end
```

You can also create the client with a block for configurations.

```ruby
client = Hatenablog::Client.new do |config|
  config.consumer_key        = 'XXXXXXXXXXXXXXXXXXXX'
  config.consumer_secret     = 'XXXXXXXXXXXXXXXXXXXX'
  config.access_token        = 'XXXXXXXXXXXXXXXXXXXX'
  config.access_token_secret = 'XXXXXXXXXXXXXXXXXXXX'
  config.user_id             = 'example-user'
  config.blog_id             = 'example-user.hatenablog.com'
end
```

### Blog

```ruby
client.title       # Get the blog title
client.author_name # Get the blog author name
```

### Feeds

```ruby
feed = client.next_feed # Get the first feed when no argument is passed
feed.uri
feed.next_uri    # The next feed URI
feed.title
feed.author_name
feed.update      # Updated datetime

feed.entries # entries in the feed
feed.each_entry do |entry|
  # ...
end
feed.has_next? # true if the next page exists
next_feed = client.next_feed(feed)
```

### Entries

```ruby
client.get_entry('0000000000000000000') # Get the entry specifed by its ID
client.entries     # Get blog entries in the first page
client.entries(1)  # Get blog entries in the first and the second page
client.all_entries # Get all entries in the blog

entry = client.post_entry(
  'Example Title',                  # title
  'This is the **example** entry.', # content
  ['Ruby', 'Rails'],                # categories
  'yes'                             # draft
)
entry.id
entry.uri
entry.edit_uri
entry.author_name
entry.title       #=> 'Example Title'
entry.content     #=> 'This is the **example** entry.'
entry.draft       #=> 'yes'
entry.draft?      #=> true
entry.categories  #=> ['Ruby', 'Rails']
entry.updated     # Updated datetime

client.update_entry(
  entry.id,
  entry.title,
  'This is the **modified** example entry.',
  entry.categories,
  'no'
)
client.delete_entry(entry.id)
```

### Categories

```ruby
categories = client.categories # Get categories registered in the blog
categories.each do |cat|
  puts cat
end

# When categories are fixed, you can only use those categories for your entries.
# ref: https://tools.ietf.org/html/rfc5023#section-7.2.1.1
categories.fixed?
```

## Contributing

1. Create your feature branch (`git checkout -b my-new-feature`)
2. Commit your changes (`git commit -am 'Add some feature'`)
3. Push to the branch (`git push origin my-new-feature`)
4. Create a new Pull Request

## License

MIT
