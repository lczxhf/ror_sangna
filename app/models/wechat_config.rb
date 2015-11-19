class WechatConfig < ActiveRecord::Base
	belongs_to :member,:dependent=>:delete
	belongs_to :sangna_config
	has_one :wechat_user,:dependent=>:delete
	self.primary_key = :id

	after_save :update_redis

	private
		def update_redis
					self.association_cache.delete_if{|b| b==:member}
					puts 'correlation'
					puts self.association_cache.collect{|a| a.first}
					result=Marshal.dump(self)
					$redis.set(openid,result,ex:6000)
		end
end
