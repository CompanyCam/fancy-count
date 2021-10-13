# frozen_string_literal: true

module FancyCount
  class RedisAdapter < Adapter
    def counter
      options = {}
      if @config.expireat
        options[:expireat] = @config.expireat
      end
      @counter ||= Redis::Counter.new(@name, options)
    end
  end
end
