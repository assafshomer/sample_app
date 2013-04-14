class AddRecieveNotificationsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :recieve_notifications, :boolean, default: true
  end
end
