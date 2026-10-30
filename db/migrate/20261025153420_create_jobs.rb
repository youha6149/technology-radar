class CreateJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :jobs do |t|
      t.references :raw_document, null: false, foreign_key: true, index: { unique: true }
      t.string :title
      t.string :company
      t.string :position
      t.json :job_types, null: false, default: []
      t.text :description
      t.integer :salary_min
      t.integer :salary_max
      t.json :technologies, null: false, default: []
      t.json :features, null: false, default: []
      t.datetime :extracted_at

      t.timestamps
    end
  end
end
