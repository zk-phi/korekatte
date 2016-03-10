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
      t.string :owner_name, :null => false
      t.timestamps
    end

    create_table :memberships do |t|
      t.string :user_name, :null => false
      t.string :group_name, :null => false
      t.boolean :pending, :null => false
      t.timestamps
    end

    create_table :wishes do |t|
      t.string :text, :null => false
      t.string :group_name, :null => false
      t.string :user_name, :null => false
      t.boolean :active, :null => false
      t.string :deactivated_by, :null => true
      t.timestamps
    end

    add_index :users, :name, :unique => true
    add_index :groups, :name, :unique => true
    add_index :memberships, [ :user_name, :group_name ], :unique => true

  end

end
