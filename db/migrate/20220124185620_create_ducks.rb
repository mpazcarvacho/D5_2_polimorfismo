class CreateDucks < ActiveRecord::Migration[5.2]
  def change
    create_table :ducks do |t|
      t.string :color

      t.timestamps
    end
  end
end
