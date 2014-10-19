class RemoveTimestampsFromRevisions < ActiveRecord::Migration
  def change
    remove_column :revisions, :created_at, :string
    remove_column :revisions, :updated_at, :string
  end
end
