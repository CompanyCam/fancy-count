# frozen_string_literal: true

require "spec_helper"

RSpec.describe FancyCount::TestAdapter do
  let(:adapter) { described_class.new("my-counter") }

  after { described_class.reset }

  describe "initialize" do
    it "loads the existing count when one exists" do
      described_class.counts = {"my-counter" => 2}
      expect(adapter.value).to eq(2)
    end
  end

  describe "increment" do
    it "increments the counter" do
      adapter.increment
      expect(adapter.value).to eq(1)
    end
  end

  describe "decrement" do
    before { described_class.counts = {"my-counter" => 2} }

    it "decrements the counter" do
      adapter.decrement
      expect(adapter.value).to eq(1)
    end
  end

  describe "change" do
    it "changes the counter" do
      adapter.change(5)
      expect(adapter.value).to eq(5)
    end
  end

  describe "reset" do
    before { described_class.counts = {"my-counter" => 2} }

    it "resets the counter" do
      adapter.reset
      expect(adapter.value).to eq(0)
    end
  end

  describe "value" do
    before { described_class.counts = {"my-counter" => 2} }

    it "returns the current value" do
      expect(adapter.value).to eq(2)
    end
  end
end
