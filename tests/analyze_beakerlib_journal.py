#!/usr/bin/env python

#
#
#

import sys
import getopt
from xml.dom.minidom import parse

def main(argv):
    func = printResult

    try:
        opts, args = getopt.getopt(argv, "ht", ["help", "testname"])
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            sys.exit(1)
        elif opt in ("-t", "--testname"):
            func = printTestname

    if len(args) != 1:
        usage()
        sys.exit(1)
    
    dom = parse(args[0])
    func(dom)
    sys.exit(0)

def printResult(dom):
    phases = dom.getElementsByTagName("phase")

    result = "PASS"
    for phase in phases:
        if phase.getAttribute("result") != "PASS":
            result = "FAIL"
    
    print(result)

def printTestname(dom):
    testName = getText(dom.getElementsByTagName("testname")[0].childNodes)
    print(testName)

def getText(nodelist):
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
    print("Usage:")
    print(" ./analyze_beakerlib_journal.py [-t|--testname] [-h|--help] xmljournalfilename")
    print("")

if __name__ == "__main__":
    main(sys.argv[1:])
