# -*- coding: utf-8 -*-
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.common.exceptions import NoSuchElementException
from selenium.common.exceptions import NoAlertPresentException
import unittest, time, re

service_args = [
'--proxy=https://proxy:8080',
'--proxy-type=http',
'--proxy-auth=username:password',
'--ssl-protocol=any',
'--ignore-ssl-errors=true'
]

class Test(unittest.TestCase):
    def setUp(self):
        self.driver = webdriver.PhantomJS("phantomjs.exe",service_args=service_args)
        self.driver.set_window_size(1120, 550)
        self.driver.implicitly_wait(30)
        self.driver.set_page_load_timeout(30)
        self.base_url = "https://dev.com.au"
        print self.base_url 
        self.verificationErrors = []
        self.accept_next_alert = True
    
    def test_(self):
        driver = self.driver
        driver.get(self.base_url + "/home")
        print self.base_url + "/home"
        driver.find_element_by_id("toggle-login").click()
        print "toggle-login click"      
        driver.find_element_by_id("usernameField").send_keys("username")
        print "username"       
        driver.find_element_by_id("passwordField").send_keys("Password")
        print "Password"            
        driver.find_element_by_xpath("(//button[@type='button'])[2]").click()
        print "(//button[@type='button'])[2] click"     

    
    def is_element_present(self, how, what):
        try: self.driver.find_element(by=how, value=what)
        except NoSuchElementException as e: return False
        return True
    
    def is_alert_present(self):
        try: self.driver.switch_to_alert()
        except NoAlertPresentException as e: return False
        return True
    
    def close_alert_and_get_its_text(self):
        try:
            alert = self.driver.switch_to_alert()
            alert_text = alert.text
            if self.accept_next_alert:
                alert.accept()
            else:
                alert.dismiss()
            return alert_text
        finally: self.accept_next_alert = True
    
    def tearDown(self):
        self.driver.close()
        self.driver.quit()
        self.assertEqual([], self.verificationErrors)

if __name__ == "__main__":
    unittest.main()
