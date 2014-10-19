class RemoveTimestampsFromProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :created_at, :string
    remove_column :projects, :updated_at, :string
  end
end
