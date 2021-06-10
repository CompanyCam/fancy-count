# frozen_string_literal: true

require "active_support/configurable"

module FancyCount
  class Configuration
    include ActiveSupport::Configurable

    config_accessor :adapter

    ADAPTER_CLASSES = {
      redis: FancyCount::RedisAdapter,
      test: FancyCount::TestAdapter
    }

    def self.adapter=(value)
      if ADAPTER_CLASSES.key?(value.to_sym)
        super(value)
      else
        raise_missing_adapter_error(value)
      end
    end

    def adapter_class
      @adapter_class ||= ADAPTER_CLASSES[adapter.to_sym]
    end

    private

    def raise_missing_adapter_error(adapter_name)
      message = %W[Missing adapter for #{adapter_name}, valid adapters are #{ADAPTER_CLASSES.keys.join(", ")}]
      raise FancyCount::MissingAdapterError.new(message)
    end
  end
end
