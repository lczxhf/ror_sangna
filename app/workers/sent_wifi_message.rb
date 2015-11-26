require 'sidekiq/api'
  class SentWifiMessage
    include Sidekiq::Worker

    def perform(user_id,openid)
    	PerUser.sent_wifi_message(user_id,openid)
    end
end