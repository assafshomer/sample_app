class CreateEmailVerifications < ActiveRecord::Migration
  def change
    create_table :email_verifications do |t|
      t.integer :user_id
      t.string :token
      t.boolean :active, default:true

      t.timestamps
    end
  end
end
