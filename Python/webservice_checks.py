#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
import time
import sys

print ""
print " Webservice Check script"
print "------------------------"

localtime = time.asctime( time.localtime(time.time()) )
print "Last Run Time=" + localtime

environment = sys.argv[1]
print "Environment=" + environment

# Session Start=OK
if os.path.isfile("F:/SoapUI/testsuite/" + environment + "/DestinationStatusGetByUser" + environment + "-TestCase_1-SessionStart__Request_1-0-OK.txt"):
   print " Session Start=OK"
   
   #Service Session Start=OK 
   if os.path.isfile("F:/SoapUI/testsuite/" + environment + "/DestinationStatusGetByUser" + environment + "-TestCase_1-ServiceSessionStart__Request_1-0-OK.txt"):
      print "Service Session Start=OK"  
	  
      #Destination Status Get By User=OK
      if os.path.isfile("F:/SoapUI/testsuite/" + environment + "/DestinationStatusGetByUser" + environment + "-TestCase_1-DestinationStatusGetByUser-0-OK.txt"):
         print "Destination Status Get By User=OK"
         
		 #Print soap endpoint url
         file = open("F:/SoapUI/testsuite/" + environment + "/DestinationStatusGetByUser" + environment + "-TestCase_1-DestinationStatusGetByUser-0-OK.txt", "r") 
         for line in file: 
	        if line.startswith("Endpoint:"):
	           Endpoint = line[10:-1]
	           print "Endpoint=<a href='" + Endpoint + "' target='_blank'>" + Endpoint + "</a>"
         file.close()
		 
		 #Print status of each service as online or offline, delimited by a tab
         print "<--table " + environment + "  web services status starts-->"   
         print "Destination\tStatus"   		 
         file = open("F:/SoapUI/testsuite/" + environment + "/DestinationStatusGetByUser" + environment + "-TestCase_1-DestinationStatusGetByUser-0-OK.txt", "r") 
         for line in file: 
	        if line.startswith("<Destination>",21):
	           Destination = line[34:-15]
	        if line.startswith("<DestinationOnline>",21):
	           DestinationOnline = line[40:-21]
	           if DestinationOnline == "true":
	              print Destination + "\t" + "Online"
	           else:
	              print Destination + "\t" + "Offline"   
         file.close()	 
         print "<--table " + environment + "  web services status ends-->"		       
		 
      else:
         print "Destination Status Get By User=FAILED"	  
   else:
      print "Service Session Start=FAILED"
else:
   print " Session Start=FAILED"



