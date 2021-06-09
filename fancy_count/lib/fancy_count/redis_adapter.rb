# frozen_string_literal: true

module FancyCount
  class RedisAdapter < Adapter
    def counter
      @counter ||= Redis::Counter.new(@name)
    end
  end
end
