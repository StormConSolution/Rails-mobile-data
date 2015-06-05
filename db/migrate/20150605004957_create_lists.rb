class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.string  :name
      t.integer :listable_id
      t.string  :listable_type
      t.timestamps null: false
    end

    add_index :lists, :listable_id

    create_table :users_lists, id: false do |t|
      t.belongs_to :user, index: true
      t.belongs_to :list, index: true
    end
  end
end