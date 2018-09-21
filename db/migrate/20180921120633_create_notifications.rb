class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.references :user, foreign_key: true
      t.references :source, polymorphic: true
      t.jsonb :content, default: { text: '', url: '', route: '', params: {} }
      t.string :status

      t.timestamps
    end
  end
end
