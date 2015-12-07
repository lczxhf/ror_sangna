  redis_server = Rails.application.secrets.redis_server
	redis_port = Rails.application.secrets.redis_port
	redis_db_num = Rails.application.secrets.redis_db_num
	redis_namespace = Rails.application.secrets.redis_namespace
  redis_password=Rails.application.secrets.redis_password	

Sidekiq.configure_server do |config|
	p redis_server
	config.redis = { url: "redis://:#{redis_password}@#{redis_server}:#{redis_port}/#{redis_db_num}", namespace: redis_namespace }
end
	
Sidekiq.configure_client do |config|
		config.redis = { url: "redis://:#{redis_password}@#{redis_server}:#{redis_port}/#{redis_db_num}", namespace: redis_namespace }
end
