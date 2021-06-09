# frozen_string_literal: true

module FancyCount
  class TestAdapter < Adapter
    @@counts = {}

    def self.reset
      self.counts = {}
    end

    def self.counts
      @@counts
    end

    def self.counts=(value)
      @@counts = value
    end

    def initialize(name)
      super(name)
      self.class.counts ||= {}
      self.class.counts[name] ||= 0
    end

    def increment
      self.class.counts[@name] += 1
    end

    def decrement
      self.class.counts[@name] -= 1
    end

    def change(value)
      self.class.counts[@name] = value
    end

    def reset
      self.class.counts[@name] = 0
    end

    def value
      self.class.counts[@name]
    end

    def delete
      self.class.counts.delete(@name)
    end
  end
end
