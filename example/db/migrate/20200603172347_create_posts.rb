class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.references :person, null: false, foreign_key: true, index: true
      t.text :title, null: false
      t.text :body, null: false

      t.timestamps
    end
  end
end
