class AddDirToProject < ActiveRecord::Migration
  def change
    add_column :projects, :dir, :string
  end
end
