# Hatenablog [![Build Status](https://travis-ci.org/kymmt90/hatenablog.svg?branch=master)](https://travis-ci.org/kymmt90/hatenablog)

A library for Hatenablog AtomPub API.
This gem supports following operations using OAuth authorization:

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

### Get OAuth keys and tokens

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

#### 3. Set up the YAML configuration file

The default configuration file name is `config.yml`:

```yml
consumer_key: <Hatena application consumer key>
consumer_secret: <Hatena application consumer secret>
access_token: <Hatena application access token>
access_token_secret: <Hatena application access token secret>
user_id: <Hatena user ID>
blog_id: <Hatenablog ID>
```

## Usage

```ruby
require 'hatenablog'

# Read the OAuth configuration from 'config.yml'
Hatenablog::Client.create do |blog|
  # Get each entry's content
  blog.entries.each do |entry|
    puts entry.content
  end

  # Post new entry
  posted_entry = blog.post_entry('Entry Title',
                                 'This is entry contents', # markdown form
								 ['Test', 'Programming'])  # categories

  # Update entry
  updated_entry = blog.update_entry(posted_entry.id,
                                    'Revised Entry Title',
							        posted_entry.content,
							        posted_entry.categories)

  # Delete entry
  blog.delete_entry(updated_entry.id)
end
```
