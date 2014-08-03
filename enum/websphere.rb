begin
	require "selenium-webdriver"
rescue 
	puts "Selenium webdriver is not installed please install it: \"gem intall selenium-webdriver\""
end
	
class Websphere
	
	def initialize(host,path,file,result_file,proxy)
		begin
			@base_url = host 	
			@path = path
			
			puts "Enumerating users on #{@base_url}"
			
			if proxy == ""
				@driver = Selenium::WebDriver.for :firefox
			else
				# Firefox profile configure proxy
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
			
			@registered = false
			
		rescue Exception => e  
  			puts e.message + "in intiliaze module Websphere"
		end
	end
	
	def register
		@driver.get(@base_url + @path)
		@driver.find_element(:id, "uid").clear
		@driver.find_element(:id, "uid").send_keys "yo_testing"
		@driver.find_element(:id, "attr_password").clear
		@driver.find_element(:id, "attr_password").send_keys "Yomero1234"
		@driver.find_element(:id, "wps.portlets.confirm_password").clear
		@driver.find_element(:id, "wps.portlets.confirm_password").send_keys "Yomero1234"
		@driver.find_element(:id, "sn").clear
		@driver.find_element(:id, "sn").send_keys "yo"
		Selenium::WebDriver::Support::Select.new(@driver.find_element(:id, "preferredLanguage")).select_by(:text, "English [en]")
		@driver.find_element(:class, "wpsButtonText").click
		@driver.find_element(:name, "ns_Z7_CGAH47L00GVLB0IAH1QQUL0011__login").click	
		@regitered = true
	end
	
	def login
		
		@driver.get(@base_url + "/wps/portal/!ut/p/b0/04_Sj9CPykssy0xPLMnMz0vMAfGjzOKd3R09TMx9DAzcw3ycDDwdPQwDA0OBXFdzoIJIoAIDHMDRAFW_gZeZIUi_h7OThY-Ru6EJxfrD9aPwOtHRGKoAjxV-rkVF-UXBqcXFQE-HZOam5peW6BfkhkYYZJkoAgAKfDPL/")
		@driver.find_element(:id, "userID").clear
		 @driver.find_element(:id, "userID").send_keys "yo_testing"
		@driver.find_element(:id, "password").clear
		@driver.find_element(:id, "password").send_keys "Yomero1234"
		@driver.find_element(:name, "submitBtn").click
		#@driver.find_element(:name, "ns_Z7_CGAH47L00GVLB0IAH1QQUL00U1__login").click
		
		if element_present?(:onclick, "javascript:if(stproxy && stproxy.isLoggedIn){stproxy.login.logout();}")		
			brute_user
		else
			puts "Login credentials didn't work. Create a user account with the following credentials: U: yo_testing P: Yomero1234"
		end
	end
	
	def brute_user
		@driver.get(@base_url,"/wps/mycontenthandler/!ut/p/digest!YOrYxI9KqTwWqgiSbNIr2g/nm/oid:wps.content.root?levels=5")
		if element_present?(:xpath, "//x:div[@id='feedContent']/x:div[79]/x:h3/x:a")
			@driver.get(:xpath, "//x:div[@id='feedContent']/x:div[79]/x:h3/x:a").click
		end
		Selenium::WebDriver::Support::Select.new(@driver.find_element(:name, "searchBy")).select_by(:text, "User ID")
		@driver.find_element(:id, "seardhFor").clear
		@driver.find_element(:id, "seardhFor").send_keys "a*"
		@driver.find_element(:css, "input.wpsButtonText").click
		@driver.find_element(:css, "img[title=\"Next Page\"]").click
		@driver.find_element(:css, "img[title=\"Next Page\"]").click
				
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

