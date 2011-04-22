#!/usr/bin/env python

import sys
from xml.dom.minidom import parse

def main(scriptName, argv):
    if len(argv) != 1:
        usage()
        exit(1)

    # Parse the XML report into DOM
    dom = parse(argv[0])
    
    # The first document child node is DocumentType, second is root node
    rootNode = dom.childNodes[1]

    # Get the branch-rate attribute of root node and convert it to
    # integer percents
    branch_rate = float(rootNode.attributes["branch-rate"].value)
    branch_coverage = int(round(branch_rate * 100))
    
    # Output without trailing newline
    sys.stdout.write(str(branch_coverage))
    exit(0)

def usage():
    pass

if __name__ == "__main__":
    main("fetch_branch_coverage.py", sys.argv[1:])
