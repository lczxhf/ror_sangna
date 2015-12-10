  require 'sidekiq/api'
    class SentTechnicianMessage
        include Sidekiq::Worker
        include Sidetiq::Schedulable
        recurrence { daily.hour_of_day([18])}
  
        def perform           
              per_user_masseuses=PerUserMasseuse.where(del:1,status:2).where(user_id:51)
              uri = URI("http://106.ihuyi.cn/webservice/sms.php?method=Submit")
              per_user_masseuses.each do |per_user_masseuse|
               if per_user_masseuse.username.present?
                 Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|
                     request= Net::HTTP::Post.new(uri,{'Content-Type'=>'application/json'})
                     request.set_form_data({"account"=>"cf_zxy0506","password"=>"zxy0506","mobile"=>"#{per_user_masseuse.username}","content"=>"您尚未完善领客云平台资料，客户无法浏览到您的信息，这将对您的点钟率造成损失。请及时登陆领客水疗（微信号：lingkespa）完善资料！"})
                     response=http.request request
                     a=response.body.dup
                     puts a
                 end
               end
               sleep 1
              end
        end
    end
