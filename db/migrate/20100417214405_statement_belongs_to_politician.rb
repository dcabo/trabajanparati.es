class StatementBelongsToPolitician < ActiveRecord::Migration
  def self.up
    remove_column :statements, :name 
    add_column :statements, :politician_id, :integer
  end

  def self.down
    add_column :statements, :name, :string
    remove_column :statements, :politician_id
  end
end
