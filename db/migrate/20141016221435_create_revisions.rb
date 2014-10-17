class CreateRevisions < ActiveRecord::Migration
  def change
    create_table :revisions do |t|
      t.references :project, index: true
      t.string :commit_id

      t.timestamps
    end
  end
end
