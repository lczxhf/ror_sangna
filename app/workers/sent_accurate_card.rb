require 'sidekiq/api'
  class SentAccurateCard
    include Sidekiq::Worker

    def perform(token,key,log_key,templete_id,url,hash,sql,record_id)
    	member_ids=$redis.get(key).split(',')
        log_ids=$redis.get(log_key).split(',')
        if !member_ids.empty?
            time=Time.now
            number=999
            sql_phrase="insert coupons_records (user_id,value,accurate_rule_id,coupons_classes_id,member_id,created_at,updated_at,number,accurate_presence_coupons_record_id,status,departure_log_id) values "
            member_ids.each_with_index do |member_id,index|
                number-=1
                sql_phrase+="(#{sql},#{member_id},'#{time.strftime('%Y-%m-%d %H:%M:%S')}','#{time.strftime('%Y-%m-%d %H:%M:%S')}','#{time.to_i}I#{number}',#{record_id},2,#{log_ids[index]}),"
            end
            sql_phrase.chop!
            if ActiveRecord::Base.connection.insert(sql_phrase).present?
                    redis_arr=[]
                    member_ids.each {|a| redis_arr<<"new_card:#{a}";redis_arr<<'true'}
                    $redis.mset(redis_arr)
                    members=Member.includes(:wechat_config).find(member_ids)
                    members.each do |member|
                        Sangna.sent_template_message(token,member.wechat_config.openid,templete_id,url,hash)
                    end
                    ActiveRecord::Base.connection.execute('update user_accurate_presence_coupons_records set sum='+members.size.to_s)
                    $redis.del(key)
                    $redis.del(log_key)
            end

        end
    end
end