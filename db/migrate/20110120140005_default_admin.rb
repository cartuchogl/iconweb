class DefaultAdmin < ActiveRecord::Migration
  def self.up
    u = User.create(
      :email => "nope@wocp.com",
      :password => "nopass",
      :password_confirmation => "nopass"
    )
    u.admin = true
    u.save!
  end

  def self.down
  end
end
