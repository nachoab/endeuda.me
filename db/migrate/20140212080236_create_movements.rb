class CreateMovements < ActiveRecord::Migration
  def change
    create_table :movements do |t|
      t.string :title, :null => false
      t.decimal :amount, :precision => 10, :scale => 2, :null => false
      t.string :type, :null => false
      t.references :added_by, index: true, :null => false
      t.references :group, index: true
      t.timestamps
    end
  end
end
