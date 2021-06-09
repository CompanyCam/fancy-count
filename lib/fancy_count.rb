# frozen_string_literal: true

require_relative "fancy_count/version"
require_relative "fancy_count/adapter"
require_relative "fancy_count/redis_adapter"
require_relative "fancy_count/test_adapter"
require_relative "fancy_count/configuration"
require_relative "fancy_count/counter"
require_relative "fancy_count/has_countable"
require_relative "fancy_count/counter_cacheable"

module FancyCount
  class Error < StandardError; end
  class MissingAdapterError < Error; end

  def self.configure
    yield config if block_given?
  end

  def self.config
    @config ||= Configuration.new
  end
end
