class Tech::UpdateController < ApplicationController

	def update
		render json: '{
    "appid":"H5D747740",
    "iOS":{
    	"version":"0.2",
    	"title":"Hello H5+(0.7.0)版本更新",
    	"note":"新增自动升级检测功能\n新增分享功能演示页面\n新增推送功能演示页面\n",
    	"url":"itms-apps://itunes.apple.com/cn/app/hello-h5+/id682211190?l=zh&mt=8"
    },
    "Android":{
    	"version":"0.2",
    	"title":"Hello H5+(0.7.0)版本更新",
    	"note":"新增自动升级检测功能\n新增分享功能演示页面\n新增推送功能演示页面\n",
    	"url":"http://192.168.1.99:3000/app/H5D747740_0727114736.apk"
    }
}'
	end
end
