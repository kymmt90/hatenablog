# coding: utf-8

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'yard'
require 'yard/rake/yardoc_task'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = Dir["test/hatenablog/*_test.rb"]
  t.verbose = true
end

YARD::Rake::YardocTask.new do |t|
  t.files = Dir["lib/*.rb"]
  t.options = %w(--debug --verbose) if $trace
end
