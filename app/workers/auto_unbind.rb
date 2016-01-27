  require 'sidekiq/api'
  class AutoUnbind
    include Sidekiq::Worker
    def perform(member_id)
        puts "#{member_id} unbind"
        member=Member.find(member_id)
        member.hand_code = nil
        member.qrcode_logs.where(status:2).update_all(status:1)
        member.save
    end
  end