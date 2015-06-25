class PerUserStaff < ActiveRecord::Base
	VALID_NUMBER_REGEX = /1[3|4|5|8][0-9]\d{4,8}/
	validates :username, presence: true, length: { is: 11 },
											 format: { with: VALID_NUMBER_REGEX },
											 uniqueness: true,
											 numericality: { only_integer: true }
	has_secure_password
  validates :password, length: { minimum: 6 }, allow_blank: true	
	
	has_secure_password
	validates :password, length: { minimum: 6 }

	# 返回指定字符串的哈希摘要
  def PerUserStaff.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

end
