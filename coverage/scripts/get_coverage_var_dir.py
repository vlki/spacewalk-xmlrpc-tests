#!/usr/bin/env python

import os, ConfigParser

if __name__ == "__main__":
    configPath = "../conf/coverage.properties"
    configAbsPath = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), configPath))

    config = ConfigParser.RawConfigParser()
    config.read(configAbsPath)
       
    print(config.get('global', 'coverage.var.dir'))
