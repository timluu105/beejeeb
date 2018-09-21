class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.integer :amount_cents, default: 0, null: false
      t.references :user, foreign_key: true
      t.references :source, polymorphic: true
      t.string :transaction_type
      t.text :details

      t.timestamps
    end
  end
end
