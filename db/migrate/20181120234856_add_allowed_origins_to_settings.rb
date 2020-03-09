class AddAllowedOriginsToSettings < ActiveRecord::Migration[5.2]
  def change
    Settings.ns('api').allowed_origins = "localhost:3000,127.0.0.1:3000,localhost:8081"
  end
end
