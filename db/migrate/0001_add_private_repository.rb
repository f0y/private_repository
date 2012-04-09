class AddPrivateRepository < ActiveRecord::Migration

  def self.up
    add_column(:repositories, "is_private", :boolean, :default => false)
  end

  def self.down
    remove_column(:repositories, "is_private")
  end
end
