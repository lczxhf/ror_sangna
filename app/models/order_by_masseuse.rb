class OrderByMasseuse<ActiveRecord::Base
			belongs_to :per_user,foreign_key: "user_id"
			belongs_to :member
			belongs_to :per_user_masseuse,foreign_key: "masseuse_id"
			belongs_to :per_user_project,foreign_key: "project_id"
			belongs_to :per_user_qr_code,foreign_key: 'hand_number'
			has_many :coupons_records,foreign_key: 'from_order_id'
			has_one  :masseuses_review,foreign_key: 'order_id'
			has_many :technician_level_remarks,foreign_key: 'order_id'
			belongs_to :qrcode_log
			self.primary_key = :id



	def get_ab_rule_test()
		ab_rule=nil
		if self.member.per_user_qr_code && coupons_class=CouponsClass.where(id:2,del:1,status:1).first
			if user_coupons_class=coupons_class.user_coupons_classes.where(user_id:self.user_id,status:1).first
				if ab_rule=coupons_class.ab_rules.where(user_id:self.user_id,original_project_id:self.project_id,status:1,del:1).first
					case ab_rule.applicable_member
					when 1
						if self.member.per_user_qr_code.sex==1
							ab_rule_id=ab_rule.id
						end
					when 2
						if self.member.per_user_qr_code.sex==2
							ab_rule_id=ab_rule.id
						end
					when 3
						if self.member.per_user_qr_code.sex==3
							ab_rule_id=ab_rule.id
					end
					when 5
						if QrcodeLog.where(member_id:self.member_id).count==1
							ab_rule_id=ab_rule.id
					end
					else
						ab_rule_id=ab_rule.id
					end
				end
			end
		end
		ab_rule_id
	end

	def get_ab_rule
		ab_rule=nil
		arr=[4]
		arr << self.member.per_user_qr_code.sex if self.member.per_user_qr_code.sex!=3
		arr << 5 if QrcodeLog.where(member_id:self.member_id).count==1
		if self.member.per_user_qr_code && coupons_class=CouponsClass.where(id:2,del:1,status:1).first
			if user_coupons_class=coupons_class.user_coupons_classes.where(user_id:self.user_id,status:1).first
				ab_rule=coupons_class.ab_rules.where(user_id:self.user_id,original_project_id:self.project_id,status:1,del:1).where("applicable_member in (#{arr.join(',')})").first
			end
		end
		ab_rule
	end
end
