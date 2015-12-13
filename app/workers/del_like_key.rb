 require 'sidekiq/api'
 class DelLikeKey
       include Sidekiq::Worker
       include Sidetiq::Schedulable
       recurrence { daily}
 
 
       def perform
           arr=$redis.scan(0,:match=>"mem_like*")
           del_keys(arr[0],arr[1])
       end
 
       def del_keys(num,arr)
            if num.to_i!=0
							 if arr.present?
                 $redis.del(arr)
							 end
                 arr_scan=$redis.scan(num,:match=>"mem_like*")
                 del_keys(arr_scan[0],arr_scan[1])
            end
       end
 end
                     
