# frozen_string_literal: true

require "spec_helper"

RSpec.describe FancyCount::HasCountable do
  before do
    FancyCount::TestAdapter.reset
    @old_adapter = FancyCount.config.adapter

    FancyCount.configure do |config|
      config.adapter = :test
    end
  end

  after do
    FancyCount::TestAdapter.reset
    FancyCount.configure do |config|
      config.adapter = @old_adapter
    end
  end

  with_model :Novelist do
    # The table block (and an options hash) is passed to Active Record migration’s `create_table`.
    table do |t|
      t.string :name
      t.timestamps null: false
    end

    # The model block is the Active Record model’s class body.
    model do
      include FancyCount::HasCountable
      fancy_counter :words_written
    end
  end

  with_model :Writer do
    table do |t|
      t.string :name
      t.timestamps null: false
    end

    model do
      include FancyCount::HasCountable

      fancy_counter :words_written,
        reconcile_on_missing: true,
        reconcile_logic: :fancy_words_written_calculation

      def fancy_words_written_calculation
        99
      end
    end
  end

  let!(:novelist) { Novelist.create!(name: "Earnest Hemmingway") }
  let!(:writer) { Writer.create!(name: "R.A. Salvator") }

  it "exposes the counter behaviors" do
    expect(novelist.fancy_words_written_count).to eq(0)

    novelist.fancy_words_written_counter.increment
    expect(novelist.fancy_words_written_count).to eq(1)

    novelist.fancy_words_written_counter.decrement
    expect(novelist.fancy_words_written_count).to eq(0)

    novelist.fancy_words_written_counter.change(3)
    expect(novelist.fancy_words_written_count).to eq(3)

    novelist.fancy_words_written_counter.reset
    expect(novelist.fancy_words_written_count).to eq(0)
  end

  it "uses existing counter values" do
    writer1 = Writer.create!(name: "Ed Greenwood")
    writer2 = Writer.create!(name: "Margaret Weiss")
    writer3 = Writer.create!(name: "Tracey Hickman")
    writers = [writer1, writer2, writer3]

    writers.each do |writer|
      cache_key = "#{writer.id}_writer_fancy_words_written_counter"
      FancyCount::TestAdapter.counts[cache_key] = 3
    end

    writers.each do |writer|
      expect(writer.fancy_words_written_count).to eq(3)
    end
  end

  it "can lazily compute/build counts that do not exist" do
    writer1 = Writer.create!(name: "Ed Greenwood")
    writer2 = Writer.create!(name: "Margaret Weiss")
    writer3 = Writer.create!(name: "Tracey Hickman")
    writers = [writer1, writer2, writer3]

    writers.each do |writer|
      expect(writer.fancy_words_written_count).to eq(99)
    end

    # Novelists do not lazy load
    Novelist.find_each do |novelist|
      expect(novelist.fancy_words_written_count).to eq(0)
    end
  end

  it "can reconcile a counter on the instance" do
    writer1 = Writer.create!(name: "Ed Greenwood")
    writer2 = Writer.create!(name: "Margaret Weiss")
    writer3 = Writer.create!(name: "Tracey Hickman")
    writers = [writer1, writer2, writer3]

    writers.each do |writer|
      cache_key = "#{writer.id}_writer_fancy_words_written_counter"
      FancyCount::TestAdapter.counts[cache_key] = 3
    end

    writers.each do |writer|
      writer.fancy_counters_reconcile(:words_written)
      expect(writer.fancy_words_written_count).to eq(99)
    end
  end

  it "can reconcile a counter on a collection" do
    writer1 = Writer.create!(name: "Ed Greenwood")
    writer2 = Writer.create!(name: "Margaret Weiss")
    writer3 = Writer.create!(name: "Tracey Hickman")
    writers = [writer1, writer2, writer3]

    writers.each do |writer|
      cache_key = "#{writer.id}_writer_fancy_words_written_counter"
      FancyCount::TestAdapter.counts[cache_key] = 3
      expect(writer.fancy_words_written_count).to eq(3)
    end

    Writer.fancy_counters_reconcile(:words_written, scope: Writer.where(id: writers[0].id))

    expect(writers[0].reload.fancy_words_written_count).to eq(99)
    expect(writers[1].reload.fancy_words_written_count).to eq(3)
    expect(writers[2].reload.fancy_words_written_count).to eq(3)

    Writer.fancy_counters_reconcile(:words_written)

    expect(writers[0].reload.fancy_words_written_count).to eq(99)
    expect(writers[1].reload.fancy_words_written_count).to eq(99)
    expect(writers[2].reload.fancy_words_written_count).to eq(99)
  end
end
