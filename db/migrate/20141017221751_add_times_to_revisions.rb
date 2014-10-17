class AddTimesToRevisions < ActiveRecord::Migration
  def change
    add_column :revisions, :epoch_time, :integer
    add_column :revisions, :time, :string
  end
end
