class CreateTables < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, :null => false
      t.string :email, :null => false
      t.string :password_hash, :null => false
      t.string :password_salt, :null => false
      t.timestamps
    end
    create_table :groups do |t|
      t.string :name, :null => false
      t.integer :owner_id, :null => false
      t.timestamps
    end
    create_table :memberships do |t|
      t.integer :user_id, :null => false
      t.integer :group_id, :null => false
      t.boolean :pending, :null => false
      t.timestamps
    end
    create_table :wishes do |t|
      t.string :text, :null => false
      t.integer :group_id, :null => false
      t.integer :user_id, :null => false
      t.boolean :active, :null => false
      t.integer :deactivated_by, :null => true
      t.timestamps
    end
  end
end
