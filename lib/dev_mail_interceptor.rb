class DevMailInterceptor
	def self.delivering_email(message)
		message.subject="#{message.to}: #{message.subject}"		
		message.to="assafshomer@gmail.com"		
	end	
end