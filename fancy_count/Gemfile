# frozen_string_literal: true

source 'https://rubygems.org'

rails_version = ENV['RAILS_VERSION']
gem 'activerecord', rails_version

if sqlite_version = ENV['SQLITE_VERSION']
  gem 'sqlite3', sqlite_version
end

gemspec
