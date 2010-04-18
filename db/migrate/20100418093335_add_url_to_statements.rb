class AddUrlToStatements < ActiveRecord::Migration
  def self.up
    add_column :statements, :url, :string
  end

  def self.down
    remove_column :statements, :url
  end
end
