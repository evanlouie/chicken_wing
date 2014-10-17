class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.references :folder, index: true
      t.string :name
      t.text :content

      t.timestamps
    end
  end
end
