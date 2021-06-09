# frozen_string_literal: true

require "spec_helper"

RSpec.describe FancyCount::RedisAdapter do
  let(:fake_counter) { double(value: 1) }
  let(:adapter) { described_class.new("my-counter") }

  before do
    allow_any_instance_of(described_class).to receive(:counter).and_return(fake_counter)
  end

  describe "increment" do
    it "increments the counter" do
      expect(fake_counter).to receive(:increment)
      adapter.increment
    end
  end

  describe "decrement" do
    it "decrements the counter" do
      expect(fake_counter).to receive(:decrement)
      adapter.decrement
    end
  end

  describe "change" do
    it "changes the counter" do
      expect(fake_counter).to receive(:value=).with(5)
      adapter.change(5)
    end
  end

  describe "reset" do
    it "resets the counter" do
      expect(fake_counter).to receive(:value=).with(0)
      adapter.reset
    end
  end

  describe "value" do
    it "returns the value of the counter" do
      expect(fake_counter).to receive(:value).and_return(3)
      expect(adapter.value).to eq(3)
    end
  end
end
