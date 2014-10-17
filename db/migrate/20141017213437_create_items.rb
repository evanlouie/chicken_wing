class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.text :content
      t.references :revision, index: true

      t.timestamps
    end
  end
end
