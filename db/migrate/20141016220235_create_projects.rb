class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :git
      t.string :name

      t.timestamps
    end
  end
end
