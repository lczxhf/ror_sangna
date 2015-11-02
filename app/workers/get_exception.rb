    require 'sidekiq/api'
      class GetException
        include Sidekiq::Worker
        def perform(info=[])
              puts "get exception"
              File.open(Rails.root.join("public",'exception.txt'),'a+') do |file|
                  file.write "
                        --------------#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}-------------
                       #{info.to_a.join("\n")}
                  "
              end
        end
      end