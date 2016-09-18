class CreateInstructions < ActiveRecord::Migration[5.0]
  def change
    create_table :instructions do |t|
      t.integer :address
      t.string :opcode
      t.integer :operand

      t.timestamps
    end
  end
end
