class CreateShareholders < ActiveRecord::Migration
  def change
    create_table :shareholders do |t|
      t.references :movement, index: true, :null => false
      t.references :user, index: true, :null => false
      t.boolean :is_payer, :default => false, :null => false
      t.boolean :is_receiver, :default => false, :null => false
    end
  end
end
