  require 'sidekiq/api'
	class RemindDueCard

 	include Sidekiq::Worker
    include Sidetiq::Schedulable
    recurrence { daily.hour_of_day(12) }
 
   def perform(last_occurrence,current_occurrence)
         puts last_occurrence
         puts current_occurrence
         coupons_records=CouponsRecord.includes(:coupons_rule,member: :wechat_config).joins(:coupons_rule).where("to_days(now()) >= to_days(date_add(coupons_records.created_at,INTERVAL coupons_rules.due_day day))-3 and coupons_records.status in (1,2)")
         hash={}
         sangna_config=coupons_records.first.per_user.sangna_config
         coupons_records.each do |record|
               openid=record.member.wechat_config.openid
               if record.coupons_rule.due_day>=3
                   if (record.created_at+record.coupons_rule.due_day.days-2.days).strftime("%Y%m%d")==Time.now.strftime("%Y%m%d")
                         hash[openid].nil? ? hash[openid] = 1 : hash[openid] += 1
                   end
               else
                   if (record.created_at+record.coupons_rule.due_day.days).strftime("%Y%m%d")==Time.now.strftime("%Y%m%d")
                       hash[openid].nil? ? hash[openid] = 1 : hash[openid] += 1
                   end
               end
         end
         hash.each do |key,value|
            CouponsRecord.sent_due_message(sangna_config,value,key)
         end
   end
 end
