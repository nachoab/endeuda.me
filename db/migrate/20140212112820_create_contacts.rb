class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.references :user, index: true, :null => false
      t.references :contact, index: true, :null => false
      t.timestamps
    end
  end
end
