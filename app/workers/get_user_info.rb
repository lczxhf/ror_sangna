require 'sidekiq/api'
  class GetUserInfo
    include Sidekiq::Worker
    sidekiq_options :retry => false
    def perform(token,id)
    	get_previous_data(token,id)
    end

    def get_previous_data(token,id,next_openid=nil,susplus=0)
        url='https://api.weixin.qq.com/cgi-bin/user/get?access_token='+token+(next_openid.nil? ? '' : "next_openid=#{next_openid}")
        info_result=JSON.parse(ThirdParty.get_to_wechat(url))
        if info_result['count'].to_i>0
            if next_openid.nil?
                    susplus=info_result['total'].to_i-info_result['count'].to_i
            end
            if arr=info_result['data']['openid']
                arr.to_a.each do |openid|
                        if !WechatConfig.where(openid:openid).first
                                wechat_config=WechatConfig.new(openid:openid,sangna_config_id: id)
                                wechat_config.del=1
                                if !wechat_config.member
                                    member=Member.create(user_id:params[:id],username:wechat_config.openid)
                                    wechat_config.member=member
                                end
                                wechat_config.save
                                Sangna.get_user_info(wechat_config.id,'wxf6a05c0e64bc48e1')
                        end
                            if susplus>0
                                    get_previous_data(token,id,info_result['next_openid'],susplus)
                            end
                end
            end
        end
    end
end