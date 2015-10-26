  require 'sidekiq/api'
  class CheckDueCard
      include Sidekiq::Worker
      include Sidetiq::Schedulable
  
      recurrence { daily.hour_of_day(12) }
 
     def perform(last_occurrence,current_occurrence)
          puts "check_due_card  #{last_occurrence}---#{current_occurrence}"
          sql = ActiveRecord::Base.connection()
          sql.update_sql 'update coupons_records as record inner join coupons_rules as rule on record.coupons_rules_id=rule.id set record.status=4 where to_days(now()) >= to_days(date_add(record.created_at,INTERVAL rule.due_day day))+1 and record.status in (1,2)'
  
      end
  end                                                                                                 
                                                                                                  
                                                                                                  
                                     