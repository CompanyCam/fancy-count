# frozen_string_literal: true

module FancyCount
  module CounterCacheable
    extend ActiveSupport::Concern

    # This is the "magic module" can should be included to automatically update
    # "fancy" counter caches defined on a corresponding model.
    #
    # Example:
    #
    # class Person < ActiveRecord::Base
    #   include FancyCount::Countable
    #
    #   fancy_counter :children
    #  end
    #
    # class Child < ActiveRecord::Base
    #   include FancyCount::CounterCacheable
    #
    #   belongs_to :parent, class_name: "Person"
    #
    #   fancy_counter_cache :children, on: :parent
    # end
    #
    # This will take care of incrementing or decrementing the children count on the Person
    # model, whenever a child record is created or destroyed.

    class_methods do
      def fancy_counter_caches
        @fancy_counter_caches ||= []
      end

      def fancy_counter_cache(name, options = {})
        counter_method_name = "fancy_#{name.to_s.singularize}_counter"
        association_name = options[:on]

        self.fancy_counter_caches << { name: name, counter_name: counter_method_name, association_name: association_name }

        after_create do
          fancy_association = public_send(association_name)
          fancy_association.public_send(counter_method_name).increment
        end

        if respond_to?(:after_discard)
          after_discard do
            fancy_association = public_send(association_name)
            fancy_association.public_send(counter_method_name).decrement
          end

          after_undiscard do
            fancy_association = public_send(association_name)
            fancy_association.public_send(counter_method_name).increment
          end
        else
          after_destroy do
            fancy_association = public_send(association_name)
            fancy_association.public_send(counter_method_name).decrement
          end
        end
      end

      def fancy_counter_cache_reconcile(name, scope: nil)
        data = fancy_counter_caches.detect { |entry| entry[:name] == name }
        raise "Unknown counter #{name}" if data.blank?

        scope ||= all
        association_data = reflect_on_association(data[:association_name])

        if association_data.polymorphic?
          scope = scope.distinct("#{data[:association_name]}_type, #{data[:association_name]}_id")
        else
          foreign_key = association_data.foreign_key
          scope = scope.distinct(foreign_key)
        end

        scope.find_each(batch_size: 100) do |record|
          record.fancy_counter_cache_reconcile(name)
        end
      end
    end

    def fancy_counter_cache_reconcile(name)
      data = self.class.fancy_counter_caches.detect { |entry| entry[:name] == name }
      raise "Unknown counter #{name}" if data.blank?

      association = public_send(data[:association_name])
      new_count = fancy_association_count(association, name)
      association.public_send(data[:counter_name]).change(new_count)
    end

    def fancy_association_count(association, counter_name)
      scope = association.public_send(counter_name)

      if association.respond_to?(:kept)
        scope = scope.kept
      end

      scope.count
    end
  end
end
