class CreateCouponOrders < ActiveRecord::Migration
  def change
    create_table :coupon_orders do |t|
			t.string :prepay_id
			t.string :code_url
			t.boolean :is_subscribe
			t.string :trade_type
			t.string :transaction_id
			t.string :state
			t.references :coupons_project
			t.references :coupons_rule
			t.references :sangna_config
			t.references :wechat_config
      t.timestamps
    end
  end
end
