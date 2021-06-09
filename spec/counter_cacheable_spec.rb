# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FancyCount::CounterCacheable do
  with_model :SuperHero do
    # The table block (and an options hash) is passed to Active Record migration’s `create_table`.
    table do |t|
      t.string :name
      t.timestamps null: false
    end

    # The model block is the Active Record model’s class body.
    model do
      include FancyCount::HasCountable

      has_many :super_powers
      has_many :weapons

      validates_presence_of :name
      fancy_counter :super_powers
      fancy_counter :weapons
    end
  end

  with_model :SuperPower do
    table do |t|
      t.string :name
      t.belongs_to :super_hero, index: false
      t.timestamps null: false
    end

    model do
      include FancyCount::CounterCacheable

      belongs_to :super_hero

      validates_presence_of :name
      fancy_counter_cache :super_powers, on: :super_hero
    end
  end

  with_model :Weapon do
    table do |t|
      t.string :name
      t.belongs_to :super_hero, index: false
      t.datetime :discarded_at
      t.timestamps null: false
    end

    model do
      include Discard::Model
      include FancyCount::CounterCacheable

      belongs_to :super_hero

      validates_presence_of :name
      fancy_counter_cache :weapons, on: :super_hero
    end
  end

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

  let!(:superman) { SuperHero.create(name: "Superman") }
  let!(:batman) { SuperHero.create(name: "Batman") }

  it 'updates the counter cache when records are created and destroyed' do
    expect(superman.fancy_super_power_count).to eq(0)

    laser_eyes = SuperPower.create!(name: "Laser Eyes", super_hero: superman)
    expect(superman.fancy_super_power_count).to eq(1)

    laser_eyes.destroy
    expect(superman.fancy_super_power_count).to eq(0)
  end

  it 'can update the counter cache when records are created and soft-deleted' do
    expect(batman.fancy_weapon_count).to eq(0)

    baterang = Weapon.create!(name: "Baterang", super_hero: batman)
    expect(batman.fancy_weapon_count).to eq(1)

    baterang.discard!
    expect(batman.fancy_weapon_count).to eq(0)

    baterang.undiscard!
    expect(batman.fancy_weapon_count).to eq(1)
  end

  it 'can reconcile counter caches' do
    SuperPower.create!(super_hero: superman, name: "Super Strength")
    SuperPower.create!(super_hero: superman, name: "Super Speed")
    SuperPower.create!(super_hero: superman, name: "Super Breath")

    superman.fancy_super_power_counter.change(0)
    expect(superman.fancy_super_power_count).to eq(0)

    SuperPower.fancy_counter_cache_reconcile(:super_powers)
    expect(superman.fancy_super_power_count).to eq(3)
  end
end
