class CreatePeople < ActiveRecord::Migration[6.0]
  def change
    create_table :people do |t|
      t.text :first_name, null: false
      t.text :last_name, null: false
      t.timestamp :date_of_birth

      t.timestamps
    end
  end
end
