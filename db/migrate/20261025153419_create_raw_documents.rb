class CreateRawDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :raw_documents do |t|
      t.string :source, null: false
      t.string :url, null: false
      t.string :content_type, null: false
      t.text :body, null: false
      t.datetime :fetched_at, null: false
      t.text :parse_error

      t.timestamps
    end
    add_index :raw_documents, :url, unique: true
  end
end
