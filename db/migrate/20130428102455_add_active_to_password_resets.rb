class AddActiveToPasswordResets < ActiveRecord::Migration
  def change
    add_column :password_resets, :active, :boolean, default: true
  end
end
