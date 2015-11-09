module ExceptionNotifier
     class MyexceptionNotifier
         def initialize(options)
         end
   
         def call(exception, options={})
                 hash=[]
                 hash << options[:env]['REQUEST_URI']
                 hash << options[:env]['QUERY_STRING']
                hash << exception.message
                hash << exception.backtrace_locations.try(:first)
                GetException.perform_async(hash)
        end
    end
  end
