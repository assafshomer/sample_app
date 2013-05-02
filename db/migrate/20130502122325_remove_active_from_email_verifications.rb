class RemoveActiveFromEmailVerifications < ActiveRecord::Migration
  def up
    remove_column :email_verifications, :active
  end

  def down
    add_column :email_verifications, :active, :boolean
  end
end
