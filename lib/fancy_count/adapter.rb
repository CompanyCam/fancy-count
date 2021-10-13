# frozen_string_literal: true

module FancyCount
  class Adapter
    def initialize(name, config)
      @name = name
      @config = config
    end

    def increment
      counter.increment
    end

    def decrement
      counter.decrement
    end

    def change(value)
      counter.value = value
    end

    def reset
      counter.value = 0
    end

    def value
      counter.value
    end

    def delete
      counter.delete
    end

    private

    def counter
      raise "Not yet implemented"
    end
  end
end
