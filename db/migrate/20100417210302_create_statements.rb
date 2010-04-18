class CreateStatements < ActiveRecord::Migration
  def self.up
    create_table :statements do |t|
      t.string :name
      t.string :entity
      t.string :position
      t.string :event
      t.date :event_date
      t.integer :total_property, :default => 0
      t.integer :total_funds, :default => 0
      t.integer :total_insurance, :default => 0
      t.integer :total_vehicles, :default => 0
      t.integer :total_cash, :default => 0
      t.integer :total_liabilities, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :statements
  end
end
