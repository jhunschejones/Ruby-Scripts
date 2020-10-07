class CreateKanji < ActiveRecord::Migration[6.0]
  def change
    create_table :kanjis do |t|
      t.string :character
      t.timestamps
    end

    add_index :kanjis, :character, unique: true
  end
end
