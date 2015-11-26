require 'sidekiq/api'
  class SentAccurateCard
    include Sidekiq::Worker

    def perform(key)
    	member_ids=$redis.get(key)
    	members=member_ids.split(',').collect do |id|
    		$redis.get("member:#{id}") || Member.find(id)
    	end
    	members.each do |member|
    		
    	end
    end
end