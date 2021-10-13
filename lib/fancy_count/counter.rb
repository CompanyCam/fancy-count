# frozen_string_literal: true

module FancyCount
  class Counter
    def initialize(name, config = nil)
      @name = name
      @config = config || ::FancyCount.config
    end

    def increment
      adapter.increment
    end

    def decrement
      adapter.decrement
    end

    def change(value)
      adapter.change(value)
    end

    def reset
      adapter.reset
    end

    def value
      adapter.value
    end

    def delete
      adapter.delete
    end

    private

    def adapter
      @adapter ||= @config.adapter_class.new(@name, @config)
    end
  end
end
