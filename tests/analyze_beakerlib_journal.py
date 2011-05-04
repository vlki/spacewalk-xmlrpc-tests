#!/usr/bin/env python
#
# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
# 
# For further information see enclosed LICENSE file
# 
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>
#

#
# This script analyzes BeakerLib XML output for various values.
# See usage for more information.
#

import sys
import getopt
from xml.dom.minidom import parse
from datetime import datetime

def main(argv):
    """
    The main script function.
    """
    func = printResult

    try:
        opts, args = getopt.getopt(argv, "htd", ["help", "testname", "duration"])
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            sys.exit(1)
        elif opt in ("-t", "--testname"):
            func = printTestname
        elif opt in ("-d", "--duration"):
            func = printDuration

    if len(args) != 1:
        usage()
        sys.exit(1)
    
    dom = parse(args[0])
    func(dom)
    sys.exit(0)

def printResult(dom):
    """
    Function parsing the overall result of test from XML DOM.
    """
    phases = dom.getElementsByTagName("phase")

    result = "PASS"
    for phase in phases:
        if phase.getAttribute("result") != "PASS":
            result = "FAIL"
    
    print(result)

def printTestname(dom):
    """
    Function parsing the full test name from XML DOM.
    """
    testName = getText(dom.getElementsByTagName("testname")[0].childNodes)
    print(testName)

def printDuration(dom):
    """
    Function parsing the duration of test from XML DOM.
    """
    startTimeStr = getText(dom.getElementsByTagName("starttime")[0].childNodes)
    endTimeStr = getText(dom.getElementsByTagName("endtime")[0].childNodes)

    fmt = "%Y-%m-%d %H:%M:%S"
    startTime = datetime.strptime(startTimeStr, fmt)
    endTime = datetime.strptime(endTimeStr, fmt)

    delta = endTime - startTime
    print(int(delta.total_seconds()))

def getText(nodelist):
    """
    Helper functions which returns the text inside given list of nodes.
    """
    rc = []
    for node in nodelist:
        if node.nodeType == node.TEXT_NODE:
            rc.append(node.data)
    return ''.join(rc)

def usage():
    """
    Prints the usage information.
    """
    print("Script analyzing the XML output of BeakerLib based test.")
    print("")
    print("If no option is given and output is analyzed as pass, PASS")
    print("is printed to stdout. FAIL is printed in case of failure.")
    print("")
    print("If option -t|--testname is given, the name of test is printed")
    print("to stdout.") 
    print("")
    print("If option -d|--duration is given, the duration of test execution")
    print("in seconds is printed to stdout.")
    print("")
    print("Usage:")
    print(" ./analyze_beakerlib_journal.py [-t|--testname] [-h|--help]")
    print("                                [-d|--duration] xmljournalfilename")
    print("")

if __name__ == "__main__":
    main(sys.argv[1:])
