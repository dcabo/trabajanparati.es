class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :statement_id
      t.text :description
      t.integer :value

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
