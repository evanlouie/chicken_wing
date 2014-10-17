class CreateFolders < ActiveRecord::Migration
  def change
    create_table :folders do |t|
      t.references :revision, index: true
      t.string :name

      t.timestamps
    end
  end
end
