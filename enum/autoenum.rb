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

class Autoenum
	def initialize(host,path,file,password,result_file,proxy,http_proxy)
		begin
			@base_url = host 	
			@path = path
			
			puts "\n\nEnumerating users on #{@base_url}"
			
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
			@username_input = ""
			@button_input = ""
			
		rescue Exception => e  
  			puts e.message + "in intiliaze module Autoenum"
		end
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
		
		puts "	Using username input: " + @username_input
		puts "	Using submit button : " + @button_input
		
	end
	
	def brute_user
		# Brute forcing user accounts based on file
		begin
			## find input values
			find_input
			#######
			
			usr = File.new(@file.to_s,'r+')
			
			@driver.manage.delete_all_cookies
			
			
			usr.each do |user|
				@driver.get(@base_url + @path)
				
				user = user.to_s.strip
				
				results = File.new(@result_file.to_s,'a+') 
				
				puts "Testing User:#{user}"
				# Test user account
				@driver.find_element(:name, @username_input).clear
				@driver.find_element(:name, @username_input).send_keys "#{user}"
				@driver.find_element(:name, @button_input).click
				
				if element_present?(:name, @button_input) 
					puts "User Account #{user} NOT found"
					@driver.manage.delete_all_cookies
				else
					puts "Valid User Account #{user}"
					results.puts user					
					@driver.manage.delete_all_cookies
				end
				results.close
			end
			
			usr.close
			
			@driver.quit
			
		rescue Exception => e  
  			puts e.message + "==> brute_user module Autoenum"
			@driver.quit
		end			
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

 