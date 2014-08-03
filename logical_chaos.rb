# David Llorens - @c4an
# 
#
#	/$$                     /$$                     /$$                 /$$                                    
#	| $$                    |__/                    | $$                | $$                                    
#	| $$  /$$$$$$   /$$$$$$  /$$  /$$$$$$$  /$$$$$$ | $$        /$$$$$$$| $$$$$$$   /$$$$$$   /$$$$$$   /$$$$$$$
#	| $$ /$$__  $$ /$$__  $$| $$ /$$_____/ |____  $$| $$       /$$_____/| $$__  $$ |____  $$ /$$__  $$ /$$_____/
#	| $$| $$  \  $$| $$  \ $$| $$| $$        /$$$$$$$| $$      | $$      | $$  \ $$  /$$$$$$$| $$  \ $$|  $$$$$$ 
#	| $$| $$  |  $$| $$  | $$| $$| $$       /$$__  $$| $$      | $$      | $$  | $$ /$$__  $$| $$  | $$ \____  $$
#	| $$|  $$$$$$/|  $$$$$$$| $$|  $$$$$$$|  $$$$$$$| $$      |  $$$$$$$| $$  | $$|  $$$$$$$|  $$$$$$/ /$$$$$$$/
#	|__/ \______/  \____  $$|__/ \_______/ \_______/|__/       \_______/|__/  |__/ \_______/ \______/ |_______/ 
#               /$$  \ $$                                                                                    
#              |  $$$$$$/                                                                                    
#               \______/                                                                                     
#
# If you don't know what you are doing don't blame the tool :)
#


	
$LOAD_PATH << File.dirname(__FILE__)


### require enum modules ########
#require 'aux/arin'
#require 'aux/http-screenshot'
#require 'aux/create_usernames'


### require enum modules ########
require 'enum/autoenum'
require 'enum/websphere'
require 'enum/qpm'
#require 'enum/sap'

### require brute modules ########
require 'bruteforce/autobrute' 
require 'bruteforce/citrix'
require 'bruteforce/citrix_vpn'
require 'bruteforce/webvpn'
require 'bruteforce/webvpn_juniper'
require 'bruteforce/ms_forefront'
require 'bruteforce/outlook'
require 'bruteforce/peoplesoft' 
require 'bruteforce/rsa' 

class Logical_Chaos
	
	def initialize
		@host = ""
		@path = "/"
		@file_usrs = "dictionaries/usrs_char_last_names_common"
		@file_results = "results/brute_force_results"
		@file_password = "dictionaries/passwd1"
		@proxy = ""
		@http_proxy = ""
		@tabs = 1
	end

	def detailed_help()
		puts "\n"
		puts "   	 /$$                     /$$                     /$$                 /$$                                 "  
		puts "  	| $$                    |__/                    | $$                | $$                                    "
		puts "	| $$  /$$$$$$   /$$$$$$  /$$  /$$$$$$$  /$$$$$$ | $$        /$$$$$$$| $$$$$$$   /$$$$$$   /$$$$$$   /$$$$$$$"
		puts "	| $$ /$$__  $$ /$$__  $$| $$ /$$_____/ |____  $$| $$       /$$_____/| $$__  $$ |____  $$ /$$__  $$ /$$_____/"
		puts "	| $$| $$  \  $$| $$  \  $$| $$| $$        /$$$$$$$| $$      | $$      | $$  \  $$  /$$$$$$$| $$  \  $$|  $$$$$$ "
		puts "	| $$| $$  | $$| $$  | $$| $$| $$       /$$__  $$| $$      | $$      | $$  | $$ /$$__  $$| $$  | $$ \____  $$"
		puts "	| $$|  $$$$$$/|  $$$$$$$| $$|  $$$$$$$|  $$$$$$$| $$      |  $$$$$$$| $$  | $$|  $$$$$$$|  $$$$$$//$$$$$$$/"
		puts "	|__/ \______/  \____    $$|__/ \_______/   \_______/|__/         \_______/|__/  |__/ \_______/ \______/ |_______/ "
		puts "                       /$$  \  $$                                                                                    "
		puts "                      |  $$$$$$/                                                                                    "
		puts "                        \______/                                                                                     "
		puts "\n\n"
		puts "logical_chaos modules:"
		puts "	|------ enumeration"
		puts "			|----- qpm		# Retrieve valid user accounts through Quest Password Manager			#"
		#puts "			|----- websphere	# Retrieve valid user accounts through Websphere				#"
		puts "			|----- autoenum		# Identify user form automatically and enumerate user accounts		        #"
		puts "	|------ bruteforce"
		puts "			|----- citrix		# Find valid user accounts through dictionaty attack on Citrix			#"
		puts "			|----- citrix_vpn	# Find valid user accounts through dictionaty attack on Citrix			#"
		puts "			|----- outlook		# Find valid user accounts through dictionaty attack on Outlook Webmail		#"
		puts "			|----- rsa		# Find valid user accounts through dictionaty attack on RSA selfservice		#"
		puts "			|----- web vpn		# Find valid user accounts through dictionaty attack on Cisco VPN		#"
		puts "			|----- sap		# Retrieve valid user accounts through SAP					#"
		puts "			|----- peoplesoft	# Find valid user accounts through dictionaty attack on Peoplesoft		#"
		puts "			|----- autobrute	# Identify login form parameters automatically and bruteforce users/passwords	#"
		puts "\n\nAvailable modules: enumerate bruteforce"
		puts"\n\nEXAMPLES:"
		puts "\n ruby logical_chaos.rb -e 	-----> Shows help for enumeration modules\n"
		puts "\n ruby logical_chaos.rb -b	-----> Shows help for bruteforce modules\n"
		puts "\n ruby logical_chaos.rb help	-----> Shows this help\n"
		puts " \n\n"
	end
	
	def check_params(params)
		#puts params.length
		
		if params.length < 4
			puts "Please review your options and parameters and try again"
			detailed_help
			return false
		end
		
		i = 0
		params.each do |param|
			i +=1
			case param			
			when "-h"
				@host  = params[i]
				puts "\n\nHost: 				#{@host}"
			when "-p"
				@path = params[i]
				puts "Path: 				#{@path}"
			when "-f"
				@file_usrs = params[i]
				puts "Users file: 			#{@file_usrs}"				
			when "-P"
				@file_password = params[i]		
				puts "Password file to use: 		#{@file_password}"
			when "-u"
				@file_results = params[i]
				puts "Users file to create: 		#{@file_results}"
			when "-s"
				@proxy = params[i]
				puts "Proxy: 				#{@proxy}"			
			when "-l"
				@http_proxy = params[i]
				puts "HTTP(S) Proxy: 			#{@http_proxy}"
			when "-t"
				@tabs = params[i].to_i
				puts "Tabs: 				#{@tabs}"
			end
		end	
		
		if @host ==""
			return false
		else
			return true
		end
	end
	
	def split_files		
		file_usrs = File.new(@file_usrs,'r+')
		length = 0
		file_usrs.each do |i|
			length +=1 
		end
		file_usrs.close
		file_usrs = File.new(@file_usrs,'r+')
		residual = @tabs - length % @tabs 
		usrs_length = length / @tabs + residual
		puts "Splitting users into files of : #{usrs_length}"
		puts "Total users to test : #{length}"
			
		
		tmp_usrs = "/tmp/usrs_tmp_"		
	
		array_filenames = Array.new
		
		tabs = 0
		lines = 0
		i=0
		file = tmp_usrs + tabs.to_s
		tmp_file = File.new(file,'w+')
		
		file_usrs.each do |line|
			if i > usrs_length
				tmp_file.puts line
				lines += 1
				tmp_file.close				
				array_filenames<< file				
				tabs +=1
				file = tmp_usrs + tabs.to_s
				tmp_file = File.new(file,'w+')
				i=0
			else
				tmp_file.puts line
				i +=1
				lines += 1
			end
		end
		
		#puts "lines: #{lines}"
		return array_filenames
	end
	def combine_results		
		i = 0		
		file_result = File.new(@file_results,'w+')
		while i<@tabs 
			tmp_file_result = "tmp_result_" + i.to_s
			file_tmp_result = File.new(tmp_file_result,'r+')
			file_tmp_result.each do |line|
				file_result.puts line
			end
			file_result.close
			file_tmp_result.close
			i +=1
		end
		
	end
	
	######################################################################################
	###############################              AUXILIARY   		###################################
	######################################################################################
	
	def aux_help
		puts "\n AUXILIARY:\n\n"
		puts " -m		[REQUIRED] Auxiliary script to use: create_users or screenshot"
		puts " -f		[OPTIONAL] Input file with a list of first names you want to use"
		puts " -l		[OPTIONAL] Input file with a list of last names you want to use"
		puts " -r		[OPTIONAL] Input Nmap for the screenshot script"
		puts " -p		[OPTIONAL] path where the result files should be written. Default: dictionaries/ or screenshot/"
		puts " -P		[OPTIONAL] Pattern you want to use to create the list of usernames. Example Clastname"
		puts " 				L - Capital case Alpha Character"
		puts " 				l - Lower case Alpha Character"
		puts " 				N - Numeric character"
		puts " 				LASTNAME - Last names listed in the file"
		puts " 				FIRSTNAME - First names listed in the file"
		puts " 				Example - LLASTNAMEN will create "
		
		puts"\n\n EXAMPLES:"
		puts "\n ruby logical_chaos.rb -b citrix -h https://X.X.X.X:80/ -p / -f /tmp/users -P dictionaries/common_passwords -u /tmp/valid_users -s 127.0.0.1:9050"
		puts " ruby logical_chaos.rb -b outlook -h https://X.X.X.X:8080/ -p / -f /tmp/users -P dictionaries/common_passwords -u /tmp/valid_users -s 127.0.0.1:9050"
		puts " ruby logical_chaos.rb -b webvpn -h https://X.X.X.X:7000/ -p / -f /tmp/users -P dictionaries/common_passwords -u /tmp/valid_users -s 127.0.0.1:9050\n"
		puts " ruby logical_chaos.rb -b peoplesoft -h https://X.X.X.X/ -p / -f /tmp/users -P dictionaries/common_passwords -u /tmp/valid_users -s 127.0.0.1:9050\n\n"
	end
	
	def create_usernames
		sap = Sap.new(@host,@path,@file_usrs,@file_results,@proxy)
		sap.brute_user
	end
	
	
	
	######################################################################################
	###############################              BRUTEFORCE 		###################################
	######################################################################################
	
	
	def bruteforce_help
		puts "\n BRUTEFORCE OPTIONS:\n\n"
		puts " -h		[REQUIRED] Target host you want to retrieve the information. Value should be in the format of HOST:PORT"
		puts " -p		[OPTIONAL] Path where the application is installed. Not needed if redirection is configured on the web application (Default path: /)"
		puts " -f		[OPTIONAL] File where the list of users to test is going to be taken from (Default: dictionaries/common_users)"
		puts " -P		[OPTIONAL] File with the list of passwords to test against all users (Default: Password1 or use dictionaries/common_passwords)"
		puts " -u		[OPTIONAL] File where to store the discovered user / password combination (Defaul: results/brute_force_results) "		
		puts " -s		[OPTIONAL] Socks proxy 127.0.0.1:9050 . If you want to use TOR default installation use port 9050"
		puts"\n\n EXAMPLES:"
		puts "\n ruby logical_chaos.rb -b citrix -h https://X.X.X.X:80/ -p / -f /tmp/users -P dictionaries/common_passwords -u /tmp/valid_users -s 127.0.0.1:9050"
		puts " ruby logical_chaos.rb -b outlook -h https://X.X.X.X:8080/ -p / -f /tmp/users -P dictionaries/common_passwords -u /tmp/valid_users -s 127.0.0.1:9050"
		puts " ruby logical_chaos.rb -b webvpn -h https://X.X.X.X:7000/ -p / -f /tmp/users -P dictionaries/common_passwords -u /tmp/valid_users -s 127.0.0.1:9050\n"
		puts " ruby logical_chaos.rb -b peoplesoft -h https://X.X.X.X/ -p / -f /tmp/users -P dictionaries/common_passwords -u /tmp/valid_users -s 127.0.0.1:9050\n\n"
	end
	
	
	
	def outlook
		puts "\n\nBruteforcing users through outlook. This might take a while please be patient ..."
		if @tabs == 1 
			outlook = Outlook.new(@host,@path,@file_usrs,@file_password,@file_results,@proxy,@http_proxy)
			outlook.brute_user_password
		else
			files_usrs,files_results = split_files
			outlook = Outlook.new(@host,@path,@file_usrs,@file_password,@file_results,@proxy,@http_proxy)
			outlook.brute_user_password
			
		end
	end
	
	def citrix
		puts "\n\nBruteforcing users / passwords automatically. This might take a while please be patient ..."			
		citrix = Citrix.new(@host,@path,@file_usrs,@file_password,@file_results,@proxy,@http_proxy)
		citrix.brute_user_password
	end
	
	def peoplesoft
		puts "\n\nBruteforcing users / passwords automatically. This might take a while please be patient ..."			
		ps = Peoplesoft.new(@host,@path,@file_usrs,@file_password,@file_results,@proxy,@http_proxy)
		ps.brute_user_password
	end
	
	def citrix_vpn
		puts "\n\nBruteforcing users / passwords automatically. This might take a while please be patient ..."	
		
		citrixvpn = Citrix_vpn.new(@host,@path,@file_usrs,@file_password,@file_results,@proxy,@http_proxy)
		citrixvpn.brute_user_password
	end
	
	def webvpn
		puts "\n\nBruteforcing users / passwords automatically. This might take a while please be patient ..."			
		webvpn = Webvpn.new(@host,@path,@file_usrs,@file_password,@file_results,@proxy,@http_proxy)
		webvpn.brute_user_password
	end
	
	def autobrute		
		puts "\n\nBruteforcing users / passwords automatically. This might take a while please be patient ..."			
		auto = Autobrute.new(@host,@path,@file_usrs,@file_password,@file_results,@proxy,@http_proxy)
		auto.brute_user_password
	end
	
	def rsa		
		puts "\n\nBruteforcing users / passwords automatically. This might take a while please be patient ..."			
		rsa = Rsa.new(@host,@path,@file_usrs,@file_password,@file_results,@proxy,@http_proxy)
		rsa.brute_user_password
	end
	
	def forefront		
		puts "\n\nBruteforcing users / passwords automatically. This might take a while please be patient ..."			
		mf = Ms_forefront.new(@host,@path,@file_usrs,@file_password,@file_results,@proxy,@http_proxy)
		mf.brute_user_password
	end
	
	def webvpn_juniper		
		puts "\n\nBruteforcing users / passwords automatically. This might take a while please be patient ..."			
		vpn = Webvpn_juniper.new(@host,@path,@file_usrs,@file_password,@file_results,@proxy,@http_proxy)
		vpn.brute_user_password
	end
	
	######################################################################################
	###############################              ENUMERATE 		###################################
	######################################################################################
	
	
	def enumerate_help
		puts "\n ENUMERATION OPTIONS:\n\n"
		puts " -h		[REQUIRED] Target host you want to retrieve the information. Value should be in the format of HOST:PORT"
		puts " -p		[OPTIONAL] Path where the application is installed. Not needed if redirection is configured on the web application (Default path: /)"
		puts " -f		[OPTIONAL] File where the list of users to test is going to be taken from (Default: dictionaries/usrs_char_last_names_common)"
		puts " -u		[OPTIONAL] File name where to include the discovered user accounts (Default: results/enumeration_usr_results)"
		puts " -s		[OPTIONAL] Socks proxy 127.0.0.1:9050 . If you want to use TOR default installation use port 9050"
		puts"\n\n EXAMPLES:"
		puts "\n ruby logical_chaos.rb -e qpm -h https://X.X.X.X:80/ -p /QPM/User/Identification/ -f /tmp/users -u /tmp/valid_users -s 127.0.0.1:9050"
		puts " ruby logical_chaos.rb -e websphere -h https://X.X.X.X:8080/ -p /wps/portal/ -f /tmp/users -u /tmp/valid_users -s 127.0.0.1:9050"
		puts " ruby logical_chaos.rb -e sap -h https://X.X.X.X:7000/ -p /sap/bc/gui/sap/its/webgui -f /tmp/users -u /tmp/valid_users -s 127.0.0.1:9050"
		puts " ruby logical_chaos.rb -e peoplesoft -h https://X.X.X.X:7000/ -p /irj/portal/ -f /tmp/users -u /tmp/valid_users -s 127.0.0.1:9050"
		puts " ruby logical_chaos.rb -e rsa -h https://X.X.X.X::9090/ -p /rsa/ -f /tmp/users -u /tmp/valid_users -s 127.0.0.1:9050\n\n\n"
		
	end
		
	def qpm
		puts "\n\nEnumerating users with QPM. This might take a while please be patient ..."
		
		qpm = QPM.new(@host,@path,@file_usrs,@file_results,@proxy,@http_proxy)
		if qpm.check_search
			qpm.search_user
		else
			qpm.brute_user
		end
	end
	
	def websphere
		ws = Websphere.new(@host,@path,@file_usrs,@file_results,@proxy,@http_proxy)
		ws.brute_user
	end	
end


lc = Logical_Chaos.new()



if ARGV.length <= 1
	case ARGV[0]
	when "help","--help", "-h", "-?"
		lc. detailed_help
	when "enumerate","e", "-e", ":e"
		lc.enumerate_help
	when "bruteforce" , ":b" , "b", "-b"
		lc.bruteforce_help
	when "aux","a", "-a", ":a"
		lc.aux_help
	else
		lc. detailed_help
	end	
	exit
end

if lc.check_params(ARGV)
	
		case ARGV[0]
		when "aux","a", "-a", ":a"
			case ARGV[1]			
			when "create_usernames"
				lc.create_username
			when "screenshot"
				lc.screenshot
			else
				puts "\n\n ERROR: The module you provided doesn't exist. Please provide a enumeration valid module.\n\n"
			end
		when "enumerate","e", "-e", ":e"
			case ARGV[1]			
			when "qpm"
				lc.qpm
			when "peoplesoft"
				lc.peoplesoft
			when "websphere"
				lc.websphere
			when "autoenum"
				lc.autoenum
			else
				puts "\n\n ERROR: The module you provided doesn't exist. Please provide a enumeration valid module.\n\n"
			end
		when "bruteforce" , ":b" , "b", "-b"
			case ARGV[1]
			when "citrix"
				lc.citrix
			when "outlook"
				lc.outlook
			when "webvpn"
				lc.webvpn
			when "peoplesoft"	
				lc.peoplesoft
			when "rsa"
				lc.rsa
			when "autobrute"
				lc.autobrute
			when "citrix_vpn"
				lc.citrix_vpn
			when "webvpn_juniper"
				lc.webvpn_juniper
			when "ms_forefront"
				lc.forefront
			when "sap"				
				lc.sap
			else
				puts "\n\n ERROR: The module you provided doesn't exist. Please provide a valid bruteforce module.\n\n"
			end
		else
			lc. detailed_help
		end
else
	lc. detailed_help
end

