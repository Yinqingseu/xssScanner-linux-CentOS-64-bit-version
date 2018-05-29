#!/usr/bin/env python2
# -*- coding: utf-8 -*-

from selenium import webdriver
from selenium.webdriver.firefox.options import Options
options = Options()
options.add_argument('-headless')
firefox_profile = webdriver.FirefoxProfile()
firefox_profile.set_preference("permissions.default.stylesheet", 2)  # 禁用样式表文件 1为允许加载
firefox_profile.set_preference("permissions.default.image", 2)  # 不加载图片
firefox_profile.set_preference("dom.ipc.plugins.enabled.libflashplayer.so", 2)  # 关flash
firefox_profile.update_preferences()  # 更新设置

driver = webdriver.Firefox(firefox_profile, timeout=10, firefox_options=options)

driver.get("http://www.baidu.com")
print driver.page_source