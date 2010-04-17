class CreateStatements < ActiveRecord::Migration
  def self.up
    create_table :statements do |t|
      t.string :name
      t.string :entity
      t.string :position
      t.string :event
      t.date :event_date
      t.integer :total_property
      t.integer :total_funds
      t.integer :total_insurance
      t.integer :total_vehicles
      t.integer :total_cash
      t.integer :total_liabilities

      t.timestamps
    end
  end

  def self.down
    drop_table :statements
  end
end
