# frozen_string_literal: true

module FancyCount
  module HasCountable
    extend ActiveSupport::Concern

    class UnknownCounterError < StandardError; end
    class MissingLogicError < StandardError; end

    # This is the module we mix into ActiveRecord models. It is responsible for
    # two things:
    #
    # * Providing an interface to the counter
    # * Deleting the counter after the record is destroyed
    #
    # Important: This do not automagically provide a working counter cache. It simple
    # exposes an interface that you can use to manage one.
    #
    # Example:
    #
    # class Person < ActiveRecord::Base
    #   include FancyCount::Countable
    #
    #   fancy_counter :phone_numbers
    # end
    #
    # bob = Person.new
    # bob.fancy_phone_number_count => 0
    # bob.fancy_phone_number_counter => <Fancy::Counter>
    #
    # Counters can be incremented:
    # bob.fancy_phone_number_counter.increment
    # bob.fancy_phone_number_count => 1
    #
    # Counters can be decremented:
    # bob.fancy_phone_number_counter.decrement
    # bob.fancy_phone_number_count => 0
    #
    # Counters can explicitly have their values set:
    # bob.fancy_phone_number_counter.change(3)
    # bob.fancy_phone_number_count => 3
    #
    # Counters can easily be reset to zero:
    # bob.fancy_phone_number_counter.reset
    # bob.fancy_phone_number_count => 0

    class_methods do
      def fancy_counters
        @fancy_counters ||= []
      end

      # DANGER: This is a VERY naive method. It is not written to be hyper performant.
      # Do not run this on Images, Locations, Videos, or other HUGE tables!!!!
      def fancy_counters_reconcile(name, scope: nil)
        scope ||= all
        scope.find_each(batch_size: 100) { |record| record.fancy_counters_reconcile(name) }
      end

      def fancy_counter(name, options = {})
        counter_method_name = "fancy_#{name.to_s.singularize}_counter"
        count_method_name = "fancy_#{name.to_s.singularize}_count"
        lazily_recalculate_counter = false

        self.fancy_counters << { name: name, counter_name: counter_method_name, reconcile_logic: options[:reconcile_logic] }

        if options[:reconcile_on_missing] && !options[:reconcile_logic]
          raise ArgumentError.new('reconcile is required')
        end

        if options[:reconcile_on_missing] && options[:reconcile_logic]
          lazily_recalculate_counter = true
        end

        define_method counter_method_name do
          counter_key = "#{id}_#{self.class.name.underscore}_#{counter_method_name}"
          current_value = fancy_counter_value(counter_key)
          counter = ::FancyCount::Counter.new(counter_key)

          if lazily_recalculate_counter && current_value.nil?
            starting_value = send(options[:reconcile_logic])
            counter.change(starting_value)
          end

          counter
        end

        define_method count_method_name do
          public_send(counter_method_name).value
        end

        if respond_to?(:after_discard)
          after_discard do
            # Remove the key/value from Redis/adapter
            public_send(counter_method_name).delete
          end
        else
          after_destroy do
            # Remove the key/value from Redis/adapter
            public_send(counter_method_name).delete
          end
        end
      end
    end

    def fancy_counter_value(counter_key)
      case FancyCount.config.adapter
      when :redis
        Redis::Objects.redis.get(counter_key)
      when :test
        FancyCount::TestAdapter.counts[counter_key]
      else
        raise "Unknown adapter: #{FancyCount.config.adapter}"
      end
    end

    def fancy_counters_reconcile(name)
      count_method_name = "fancy_#{name.to_s.singularize}_count"
      data = self.class.fancy_counters.detect { |entry| entry[:name] == name.to_sym }
      raise UnknownCounterError.new("#{count_method_name} doesn't exist") if data.nil?
      raise MissingLogicError.new("#{count_method_name} doesn't have ':reconcile'") unless data.has_key?(:reconcile_logic)

      new_count = send(data[:reconcile_logic])
      public_send(data[:counter_name]).change(new_count)
    end
  end
end
