class CreateReactions < ActiveRecord::Migration[8.0]
  def change
    create_table :reactions do |t|
      t.references :job, null: false, foreign_key: true, index: { unique: true }
      t.integer :verdict, null: false

      t.timestamps
    end
  end
end
