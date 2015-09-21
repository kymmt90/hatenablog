#!/usr/bin/env ruby
# coding: utf-8

require './hatenablog'

hatenablog = Hatena::HatenaBlog.create
puts "# Entries\n"
puts hatenablog.entries

puts "\n" + ('-' * 50)

puts "\n# Categories\n"
puts hatenablog.categories

res = hatenablog.publish('test article', '# test header', ['test', 'diary'])
puts res
