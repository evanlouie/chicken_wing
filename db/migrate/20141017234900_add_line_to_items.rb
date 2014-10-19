class AddLineToItems < ActiveRecord::Migration
  def change
    add_column :items, :line_count, :integer
  end
end
