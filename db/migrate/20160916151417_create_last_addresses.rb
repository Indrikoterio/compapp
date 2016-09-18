class CreateLastAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :last_addresses do |t|
      t.integer :address

      t.timestamps
    end
  end
end
