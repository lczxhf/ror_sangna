class AddMemberRefToWechatConfig < ActiveRecord::Migration
  def change
    add_reference :wechat_configs, :member, index: true
  end
end
