class AddSmellCountToItems < ActiveRecord::Migration
  def change
    add_column :items, :smell_count, :integer
  end
end
