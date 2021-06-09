# frozen_string_literal: true

require "spec_helper"

RSpec.describe FancyCount::Counter do
  let(:adapter_class) { FancyCount::TestAdapter }
  let(:config) { double(adapter_class: adapter_class) }
  let(:counter) { described_class.new("my-counter", config) }

  before { adapter_class.reset }
  after { adapter_class.reset }

  describe "increment" do
    it "increments the counter" do
      counter.increment
      expect(counter.value).to eq(1)
    end
  end

  describe "decrement" do
    before { adapter_class.counts = {"my-counter" => 2} }

    it "decrements the counter" do
      counter.decrement
      expect(counter.value).to eq(1)
    end
  end

  describe "change" do
    it "changes the counter" do
      counter.change(5)
      expect(counter.value).to eq(5)
    end
  end

  describe "reset" do
    before { adapter_class.counts = {"my-counter" => 2} }

    it "resets the counter" do
      counter.reset
      expect(counter.value).to eq(0)
    end
  end

  describe "value" do
    before { adapter_class.counts = {"my-counter" => 2} }

    it "returns the current value" do
      expect(counter.value).to eq(2)
    end
  end
end
