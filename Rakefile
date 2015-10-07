# coding: utf-8

require 'bundler/gem_tasks'
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = Dir["test/*_test.rb"]
  t.verbose = true
end
