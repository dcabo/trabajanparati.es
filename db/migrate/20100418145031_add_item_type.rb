class AddItemType < ActiveRecord::Migration
  def self.up
    add_column :items, :item_type, :string, :limit => 1
  end

  def self.down
    remove_column :items, :item_type
  end
end
