class DeleteColumns < ActiveRecord::Migration
  def change
    remove_column :meetups, :name, :string
    remove_column :meetups, :description, :text
    remove_column :meetups, :location, :string
  end
end
