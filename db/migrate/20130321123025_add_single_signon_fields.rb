class AddSingleSignonFields < ActiveRecord::Migration
  def up
    add_column :users, :fb_access_token, :string
    add_column :users, :twitter_token, :string
    add_column :users, :twitter_secret, :string
    add_column :users, :twitter_client_info, :text
  end

  def down
    remove_column :users, :fb_access_token, :string
    remove_column :users, :twitter_token, :string
    remove_column :users, :twitter_secret, :string
    remove_column :users, :twitter_client_info, :text
  end
end
