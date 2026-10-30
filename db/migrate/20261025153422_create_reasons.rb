class CreateReasons < ActiveRecord::Migration[8.0]
  def change
    create_table :reasons do |t|
      t.references :reaction, null: false, foreign_key: true
      t.string :aspect, null: false
      t.text :comment

      t.timestamps
    end
    add_index :reasons, :aspect
  end
end
