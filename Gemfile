# frozen_string_literal: true

source "https://rubygems.org"

rails_version = ENV["RAILS_VERSION"]
gem "activerecord", rails_version

sqlite_version = ENV["SQLITE_VERSION"]

if sqlite_version.present?
  gem "sqlite3", sqlite_version
end

gemspec
