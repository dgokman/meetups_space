class CreateColumns < ActiveRecord::Migration
  def change
    add_column :meetups, :name, :string
    add_column :meetups, :description, :text
    add_column :meetups, :location, :string
  end
end
