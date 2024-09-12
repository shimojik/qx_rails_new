class CreateCreations < ActiveRecord::Migration[7.1]
  def change
    create_table :creations do |t|
      t.string :uid, index: true
      t.string :content_service
      t.string :evaluation_service
      t.json :original_prompt
      t.text :original_prompt_body
      t.json :content
      t.text :content_body
      t.text :evaluation_process
      t.float :evaluation_score
      t.text :evaluation_comment
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
