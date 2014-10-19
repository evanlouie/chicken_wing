class RemoveTimestampsFromItems < ActiveRecord::Migration
  def change
    remove_column :items, :created_at, :string
    remove_column :items, :updated_at, :string
  end
end
